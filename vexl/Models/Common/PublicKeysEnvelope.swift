//
//  PublicKeysEnvelope.swift
//  vexl
//
//  Created by Adam Salih on 29.09.2022.
//

import Foundation

class PKsEnvelope {
    let contacts: ContactPKsEnvelope
    let groups: [GroupPKsEnvelope]
    let userPublicKey: String

    lazy var allPublicKeys: [String] = {
        Array(Set(contacts.firstDegree + contacts.secondDegree + groups.flatMap(\.publicKeys) + [userPublicKey]))
    }()

    init(contacts: ContactPKsEnvelope, groups: [GroupPKsEnvelope], userPublicKey: String) {
        self.contacts = contacts
        self.groups = groups
        self.userPublicKey = userPublicKey
    }

    var isEmpty: Bool {
        contacts.firstDegree.isEmpty
        && contacts.secondDegree.isEmpty
        && groups.reduce(true) { $0 && $1.publicKeys.isEmpty }
    }

    func generatePrivateParts(symmetricKey: String) -> [OfferPayloadPrivateWrapper] {
        var hashMap = allPublicKeys.reduce(into: [String: OfferPayloadPrivate]()) { partialResult, publicKey in
            partialResult[publicKey] = OfferPayloadPrivate(commonFriends: [], friendLevel: [], symmetricKey: symmetricKey)
        }
        contacts.firstDegree.forEach { publicKey in
            hashMap[publicKey]?.friendLevel.append(AnonymousProfileType.firstDegree.rawValue)
        }
        contacts.secondDegree.forEach { publicKey in
            hashMap[publicKey]?.friendLevel.append(AnonymousProfileType.secondDegree.rawValue)
        }
        groups.flatMap(\.publicKeys).forEach { publicKey in
            hashMap[publicKey]?.friendLevel.append(AnonymousProfileType.group.rawValue)
        }
        hashMap[userPublicKey]?.commonFriends.append(AnonymousProfileType.firstDegree.rawValue)
        return hashMap.map { OfferPayloadPrivateWrapper(userPublicKey: $0.key, payloadPrivate: $0.value) }
    }

    func subset(for offer: ManagedOffer) -> PKsEnvelope {
        PKsEnvelope(
            contacts: ContactPKsEnvelope(
                firstDegree: contacts.firstDegree,
                secondDegree: offer.friendLevels.contains(.secondDegree) ? contacts.secondDegree : []
            ),
            groups: offer.group?.uuid != nil
                ? groups.filter { $0.group.uuid == offer.group?.uuid }
                : [],
            userPublicKey: userPublicKey
        )
    }
}

struct ContactPKsEnvelope {
    var firstDegree: [String]
    var secondDegree: [String]

    func publicKeys(for type: AnonymousProfileType) -> [String] {
        switch type {
        case .firstDegree:
            return firstDegree
        case .secondDegree:
            return secondDegree
        case .group:
            return []
        }
    }

    var hashMap: [String: [AnonymousProfileType]] {
        var hashMap = Set(firstDegree + secondDegree).reduce(into: [String: [AnonymousProfileType]]()) { partialResult, publicKey in
            partialResult[publicKey] = []
        }
        firstDegree.forEach { publicKey in
            hashMap[publicKey]?.append(AnonymousProfileType.firstDegree)
        }
        secondDegree.forEach { publicKey in
            hashMap[publicKey]?.append(AnonymousProfileType.secondDegree)
        }
        return hashMap
    }
}

struct GroupPKsEnvelope {
    var group: ManagedGroup
    var publicKeys: [String]
}
