//
//  EncryptionService.swift
//  vexl
//
//  Created by Adam Salih on 14.07.2022.
//

import Foundation
import Combine

protocol EncryptionServiceType {
    func hashContacts(contacts: [ContactInformation]) -> AnyPublisher<[(ContactInformation, String)], Error>
    func encryptOffer(withContactKey publicKeys: [String], offer: ManagedOffer) -> AnyPublisher<[OfferPayload], Error>
}

final class EncryptionService: EncryptionServiceType {
    @Inject var cryptoService: CryptoServiceType

    func hashContacts(contacts: [ContactInformation]) -> AnyPublisher<[(ContactInformation, String)], Error> {
        let phoneNumber = Formatters.phoneNumberFormatter
        let countryCode = phoneNumber.countryCode(for: Locale.current.regionCode ?? "")
        return contacts
            .publisher
            .withUnretained(self)
            .flatMap { owner, contact -> AnyPublisher<(ContactInformation, String), Error> in
                owner.hashContact(contact: contact, countryCode: countryCode)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    private func hashContact(contact: ContactInformation, countryCode: UInt64?) -> AnyPublisher<(ContactInformation, String), Error> {
        Future { promise in
//            DispatchQueue(label: "ContactHMAC", qos: .userInitiated).async {
                let identifier = contact.sourceIdentifier
                let trimmedIdentifier = identifier.removeWhitespaces()
                let formattedIdentifier: String = {
                    if let countryCode = countryCode, !trimmedIdentifier.contains("+") {
                        return "\(countryCode)\(trimmedIdentifier)"
                    }
                    return trimmedIdentifier
                }()
                do {
                    let hmac = try formattedIdentifier.hmac.hash(password: Constants.contactsHashingPassword)
                    promise(.success((contact, hmac)))
                } catch {
                    promise(.failure(error))
                }
//            }
        }
//        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func encryptOffer(withContactKey publicKeys: [String], offer: ManagedOffer) -> AnyPublisher<[OfferPayload], Error> {
        publicKeys
            .publisher
            .flatMap { [weak self] publicKey -> AnyPublisher<OfferPayload, Error> in
                guard let owner = self else {
                    return Fail(error: EncryptionError.dataEncryption)
                        .eraseToAnyPublisher()
                }
                // TODO: [common friends] load common firends from offer
                return owner.encrypt(offer: offer, publicKey: publicKey, commonFriends: [])
            }
            .collect()
            .eraseToAnyPublisher()
    }

    private func encrypt(offer: ManagedOffer, publicKey contactPublicKey: String, commonFriends: [String]) -> AnyPublisher<OfferPayload, Error> {
        Future { promise in
//            DispatchQueue(label: "OfferEncryption", qos: .userInitiated).async {
                do {
                    promise(.success(try OfferPayload(offer: offer, encryptionPublicKey: contactPublicKey, commonFriends: commonFriends)))
                } catch {
                    promise(.failure(error))
                }
//            }
        }
//        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
