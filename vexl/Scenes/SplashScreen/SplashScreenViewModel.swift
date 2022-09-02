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

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case tap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var animationState: AnimationState = .smallLogo
    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case loadingFinished
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
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
            .sink(receiveValue: { owner, initialScreen -> Void in
                owner.initialScreenManager.finishInitialLoading()
                owner.initialScreenManager.update(state: initialScreen)
                owner.route.send(.loadingFinished)
            })
            .store(in: cancelBag)
    }
}
