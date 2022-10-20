//
//  EncryptionService.swift
//  vexl
//
//  Created by Adam Salih on 14.07.2022.
//

import Foundation
import Combine
import KeychainAccess

typealias OfferEncprytionInput = (receiverPublicKey: String, commonFriends: [String])

protocol EncryptionServiceType {
    func hashContacts(contacts: [ContactInformation]) -> AnyPublisher<[(ContactInformation, String)], Error>
    func encryptOfferPayloadPrivateParts(privateParts: [OfferPayloadPrivateWrapper]) -> AnyPublisher<[OfferPayloadPrivateWrapperEncrypted], Error>
    func encryptOfferPayloadPublic(offer: ManagedOffer, symetricKey: String) -> AnyPublisher<String, Error>
}

final class EncryptionService: EncryptionServiceType {
    @Inject var cryptoService: CryptoServiceType
    @KeychainStore(key: .userCountryCode)
    private var userCountryCode: String?

    let hashingQueue: OperationQueue = .init()
    let encryptionQueue: OperationQueue = .init()

    func hashContacts(contacts: [ContactInformation]) -> AnyPublisher<[(ContactInformation, String)], Error> {
        let countryCode = userCountryCode
        return contacts
            .publisher
            .withUnretained(self)
            .flatMap { owner, contact -> AnyPublisher<(ContactInformation, String), Error> in
                owner.hashContact(contact: contact, countryCode: countryCode)
            }
            .collect()
            .eraseToAnyPublisher()
    }

    private func hashContact(contact: ContactInformation, countryCode: String?) -> AnyPublisher<(ContactInformation, String), Error> {
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

    func encryptOfferPayloadPrivateParts(privateParts: [OfferPayloadPrivateWrapper]) -> AnyPublisher<[OfferPayloadPrivateWrapperEncrypted], Error> {
        privateParts
            .publisher
            .flatMap { privatePart in
                Future { [weak self] promise in
                    guard let owner = self else {
                        promise(.failure(EncryptionError.dataEncryption))
                        return
                    }
                    owner.encryptionQueue.addOperation {
                        do {
                            let encryptedPart = OfferPayloadPrivateWrapperEncrypted(
                                userPublicKey: privatePart.userPublicKey,
                                payloadPrivate: try privatePart.payloadPrivate
                                    .asJsonString()
                                    .ecc.encrypt(publicKey: privatePart.userPublicKey)
                                    .encode(version: OfferPayloadPrivateVersion.v1)
                            )
                            promise(.success(encryptedPart))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .collect()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func encryptOfferPayloadPublic(offer: ManagedOffer, symetricKey: String) -> AnyPublisher<String, Error> {
            Future { [weak self] promise in
                guard let owner = self else {
                    promise(.failure(EncryptionError.dataEncryption))
                    return
                }
                owner.encryptionQueue.addOperation {
                    do {
                        let encryptedPart = try OfferPayloadPublic(offer: offer)
                            .asJsonString()
                            .aes.encrypt(password: symetricKey)
                            .encode(version: OfferPayloadPublicVersion.v1)
                        promise(.success(encryptedPart))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
