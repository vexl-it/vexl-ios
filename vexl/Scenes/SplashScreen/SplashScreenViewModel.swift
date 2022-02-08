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

    // MARK: - Dependnecies

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var authenticationManager: AuthenticationManager

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case tap
    }

    let action: Action<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoadingCountries: Bool = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case loadingFinished
    }

    var route: Coordinating<Route> = .init()

    @Published var primaryActivity: Activity = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupDataUpdates()
    }

    deinit {
        print("SPLASH VIEWMODEL DEINIT")
    }

    private func setupDataUpdates() {
        initialScreenManager.finishInitialLoading()

        let userSignedOut: AnyPublisher<InitialScreenManager.State, Never> = authenticationManager
            .$authenticationState
            .filter { $0 == .signedOut }
            .map { _ in .onboarding }
            .eraseToAnyPublisher()

        let refresh = authenticationManager.$authenticationState
            .filter { $0 == .signedIn }
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<InitialScreenManager.State, Never> in
                Just(())
                    // TODO: Load initial data
//                    .flatMap(dependency.cartManager.refresh)
//                    .flatMap(dependency.userManager.update)
                    .map { _ -> InitialScreenManager.State in
                        .onboarding
                    }
                    .track(activity: owner.primaryActivity)
            }

        Publishers.Merge(userSignedOut, refresh)
            .delay(for: 1, scheduler: RunLoop.main) // wait for lottie animation to complete
            .withUnretained(self)
            .sink(receiveValue: { owner, initialScreen -> Void in
                owner.initialScreenManager.update(state: initialScreen)
                owner.route.send(.loadingFinished)
            })
            .store(in: cancelBag)
    }
}
