//
//  OfferPayloadEncoder.swift
//  vexl
//
//  Created by Adam Salih on 22.10.2022.
//

import Foundation
import Combine
import Cleevio

class OfferRequestPayloadEncoder {
    @Inject private var encryptionService: EncryptionServiceType
    @Inject private var offerService: OfferServiceType

    @Published private var encryptedItemsCount: Int
    @Published private var maxEncryptedItemsCount: Int

    var progressPublisher: AnyPublisher<(Int, Int), Never> {
        Publishers.CombineLatest(
            $encryptedItemsCount.receive(on: DispatchQueue.main),
            $maxEncryptedItemsCount.receive(on: DispatchQueue.main)
        )
        .eraseToAnyPublisher()
    }

    private var progressInput: PassthroughSubject<Void, Never> = .init()

    private let encryptionQueue: OperationQueue = .init()
    private let progressQueue: OperationQueue = .init()
    private let cancelBag: CancelBag = .init()

    init(encryptedItemsCount: Int = 0, maxEncryptedItemsCount: Int = 0) {
        self.encryptedItemsCount = encryptedItemsCount
        self.maxEncryptedItemsCount = maxEncryptedItemsCount
        progressQueue.maxConcurrentOperationCount = 1
        progressInput
            .receive(on: progressQueue)
            .withUnretained(self)
            .sink { owner in
                owner.encryptedItemsCount += 1
            }
            .store(in: cancelBag)

    }

    func resetCounter() {
        maxEncryptedItemsCount = 0
        encryptedItemsCount = 0
    }

    func encode(offer: ManagedOffer, envelope: PKsEnvelope) -> AnyPublisher<OfferRequestPayload, Error> {
        guard let symmetricKey = offer.symmetricKey else {
            return Fail(error: AESError.couldNotGeneratePassword)
                .eraseToAnyPublisher()
        }
        guard let expiration = offer.expirationDate?.timeIntervalSince1970, let offerType = offer.type else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }

        let envelopeCount = envelope.allPublicKeys.count

        progressQueue.addOperation { [weak self] in
            self?.maxEncryptedItemsCount += envelopeCount
        }

        let chuncks = offerService
            .generateOfferPayloadPrivateParts(envelope: envelope, symmetricKey: symmetricKey)

        let privatePartEncryption = chuncks
            .withUnretained(self)
            .flatMap { [encryptionService] owner, payloads in
                payloads.publisher
                    .flatMap { [encryptionService] privatePart in
                        encryptionService.encryptOfferPayload(privatePart: privatePart)
                    }
                    .withUnretained(owner)
                    .handleEvents(receiveOutput: { owner, _ in
                        owner.progressInput.send(())
                    })
                    .map { $0.1 }
                    .collect()
            }
            .eraseToAnyPublisher()

        let publicPartEncryption = privatePartEncryption
            .flatMap { [encryptionService] privateParts -> AnyPublisher<(String, [OfferPayloadPrivateWrapperEncrypted]), Error> in
                encryptionService
                    .encryptOfferPayloadPublic(offer: offer, symmetricKey: symmetricKey)
                    .map { ($0, privateParts) }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.progressInput.send(())
            })
            .map { $0.1 }

        let requestPayload = publicPartEncryption
            .withUnretained(self)
            .map { (owner, tupl) -> OfferRequestPayload in
                let (publicPart, privateParts) = tupl
                return OfferRequestPayload(
                    offerType: offerType.rawValue,
                    expiration: Int(expiration),
                    payloadPublic: publicPart,
                    offerPrivateList: privateParts
                )
            }
            .eraseToAnyPublisher()

        return requestPayload
    }

    func encode(offers: [ManagedOffer], envelope: PKsEnvelope) -> AnyPublisher<[(ManagedOffer, OfferRequestPayload)], Error>{
        Just(offers)
            .flatMap(\.publisher)
            .withUnretained(self)
            .flatMap { owner, offer -> AnyPublisher<(ManagedOffer, OfferRequestPayload), Error> in
                let subsetEnvelope = envelope.subset(for: offer)
                return owner.encode(offer: offer, envelope: subsetEnvelope)
                    .map { (offer, $0) }
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()
    }


}