//
//  PublicKeysEnvelope.swift
//  vexl
//
//  Created by Adam Salih on 29.09.2022.
//

import Foundation

struct PKsEnvelope {
    var contacts: ContactPKsEnvelope
    var groups: [GroupPKsEnvelope]
    var userPublicKey: String

    var allPublicKeys: [String] {
        contacts.firstDegree + contacts.secondDegree + groups.flatMap(\.publicKeys) + [userPublicKey]
    }

    func generatePrivateParts(symetricKey: String) -> [OfferPayloadPrivateWrapper] {
        var hashMap = allPublicKeys.reduce(into: [String: OfferPayloadPrivate]()) { partialResult, publicKey in
            partialResult[publicKey] = OfferPayloadPrivate(commonFriends: [], friendLevel: [], symetricKey: symetricKey)
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
}

struct GroupPKsEnvelope {
    var group: ManagedGroup
    var publicKeys: [String]
}
