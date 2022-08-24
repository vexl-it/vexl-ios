//
//  EncryptionService.swift
//  vexl
//
//  Created by Adam Salih on 14.07.2022.
//

import Foundation
import Combine

typealias OfferEncprytionInput = (receiverPublicKey: String, commonFriends: [String])

protocol EncryptionServiceType {
    func hashContacts(contacts: [ContactInformation]) -> AnyPublisher<[(ContactInformation, String)], Error>
    func encryptOffer(withContactKey publicKeys: [OfferEncprytionInput], offer: ManagedOffer) -> AnyPublisher<[OfferPayload], Error>
}

final class EncryptionService: EncryptionServiceType {
    @Inject var cryptoService: CryptoServiceType
    let hashingQueue: OperationQueue = .init()
    let encryptionQueue: OperationQueue = .init()

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
        Future { [weak self] promise in
            guard let owner = self else {
                promise(.failure(EncryptionError.dataEncryption))
                return
            }
            owner.hashingQueue.addOperation {
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
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func encryptOffer(withContactKey publicKeys: [OfferEncprytionInput], offer: ManagedOffer) -> AnyPublisher<[OfferPayload], Error> {
        publicKeys
            .publisher
            .flatMap { [weak self] receiverPublicKey, commonFriends -> AnyPublisher<OfferPayload, Error> in
                guard let owner = self else {
                    return Fail(error: EncryptionError.dataEncryption)
                        .eraseToAnyPublisher()
                }
                return owner.encrypt(offer: offer, publicKey: receiverPublicKey, commonFriends: commonFriends)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    private func encrypt(offer: ManagedOffer, publicKey contactPublicKey: String, commonFriends: [String]) -> AnyPublisher<OfferPayload, Error> {
        Future { [weak self] promise in
            guard let owner = self else {
                promise(.failure(EncryptionError.dataEncryption))
                return
            }
            owner.encryptionQueue.addOperation {
                do {
                    promise(.success(try OfferPayload(offer: offer, encryptionPublicKey: contactPublicKey, commonFriends: commonFriends)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
