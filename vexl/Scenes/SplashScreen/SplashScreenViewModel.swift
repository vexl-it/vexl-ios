//
//  SplashScreenViewModel.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI
import Combine
import Cleevio

final class SplashScreenViewModel: ViewModelType {

    enum AnimationState {
        case smallLogo
        case bigLogo

        var height: CGFloat {
            switch self {
            case .smallLogo:
                return 34
            case .bigLogo:
                return 80
            }
        }
    }

    // MARK: - Dependencies

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var authenticationManager: AuthenticationManager
    @Inject var offerManager: OfferManagerType
    @Inject var offerRepository: OfferRepositoryType
    @Inject var offerService: OfferServiceType
    @Inject var userRepository: UserRepositoryType
    @Inject var persistenceManager: PersistenceStoreManagerType
    @Inject var profileManager: AnonymousProfileManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case tap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var animationState: AnimationState = .smallLogo
    @Published var showReencryptionProgress: Bool = false
    @Published var currentEncryptedItemCount: Int = 0
    @Published var maxEncryptedItemCount: Int = 0
    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case loadingFinished
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let offerEncoder: OfferRequestPayloadEncoder = .init()
    private let reencryptionRequestQueue: OperationQueue = .init()
    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        reencryptionRequestQueue.maxConcurrentOperationCount = 2

        setupAnimationUpdates()
        setupDataUpdates()
    }

    private func setupAnimationUpdates() {
        Just(())
            .delay(for: 0.5, scheduler: RunLoop.main)
            .map { _ in AnimationState.bigLogo }
            .assign(to: &$animationState)
    }

    private func setupDataUpdates() {
        let userSignedOut: AnyPublisher<InitialScreenManager.State, Never> = authenticationManager
            .isUserLoggedInPublisher
            .filter { !$0 }
            .map { _ in .initial }
            .eraseToAnyPublisher()

        let refresh = authenticationManager
            .isUserLoggedInPublisher
            .filter { $0 }
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<InitialScreenManager.State, Never> in
                Just(())
                    .map { _ -> InitialScreenManager.State in
                        .home
                    }
                    .track(activity: owner.primaryActivity)
            }

        Publishers.Merge(userSignedOut, refresh)
            .delay(for: 2, scheduler: RunLoop.main) // wait for lottie animation to complete
            .withUnretained(self)
            .flatMap { owner, initialScreen in
                owner.v2Reencrypt()
                    .map { initialScreen }
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, initialScreen -> Void in
                owner.initialScreenManager.finishInitialLoading()
                owner.initialScreenManager.update(state: initialScreen)
                owner.route.send(.loadingFinished)
            })
            .store(in: cancelBag)
    }

    private func v2Reencrypt() -> AnyPublisher<Void, Never> {
        guard let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey else {
            return Just(()).eraseToAnyPublisher()
        }

        let oldOffers = offerRepository
            .getUsersOffersWithoutSymetricKey()
            .share()

        let noOffers = oldOffers
            .filter(\.isEmpty)
            .asVoid()

        let offers = oldOffers
            .filter(\.isEmpty.not)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, offers in
                offers.forEach { offer in
                    offer.generateSymmetricKey()
                }
                if !offers.isEmpty {
                    owner.showReencryptionProgress = true
                }
            })
            .map(\.1)

        let pks = offers
            .flatMap { [offerService] offers in
                offerService.getReceiverPublicKeys(
                        friendLevel: .all,
                        groups: offers.compactMap(\.group),
                        includeUserPublicKey: userPublicKey
                    )
                    .map { envelope in (envelope, offers) }
                    .eraseToAnyPublisher()
            }

        let contactsUpdate = pks
            .flatMap { [profileManager] envelope, offers in
                profileManager.registerNewProfiles(envelope: envelope.contacts)
                    .map { (envelope, offers) }
            }

        let payloads = pks
            .withUnretained(self)
            .flatMap { owner, tupl in
                owner.offerEncoder.encode(offers: tupl.1, envelope: tupl.0)
            }

        let switchContext = payloads
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.showReencryptionProgress = false
            })
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .handleEvents(receiveOutput: { owner, payloads in
                owner.currentEncryptedItemCount = 0
                owner.maxEncryptedItemCount = payloads.count
                owner.showReencryptionProgress = true
            })

        let requests: AnyPublisher<[(ManagedOffer, OfferPayload)], Error> = switchContext
            .flatMap(\.1.publisher)
            .flatMap { [offerService] offer, payload in
                offerService.createOffer(offerPayload: payload)
                    .map { (offer, $0) }
            }
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.currentEncryptedItemCount += 1
            })
            .map(\.1)
            .collect()
            .eraseToAnyPublisher()

        let update = requests
            .flatMap { [persistenceManager] offerReposnses -> AnyPublisher<Void, Error> in
                let context = persistenceManager.viewContext
                return persistenceManager.update(context: context) { context -> Void in
                    offerReposnses.map { offer, response in
                        offer.offerID = response.offerId
                        offer.adminID = response.adminId
                    }
                }
                .eraseToAnyPublisher()
            }

        return Publishers.Merge(update, noOffers)
            .justOnError()
            .handleEvents(receiveOutput: { [offerManager] in
                offerManager.resetSyncDate()
            })
            .eraseToAnyPublisher()
    }
}
