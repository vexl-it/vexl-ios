//
//  InitialScreenService.swift
//  pilulka
//
//  Created by Adam Salih on 07.10.2021.
//

import Foundation
import Combine
import Cleevio

extension InitialScreenManager {
    enum State {
        case splashScreen
        case onboarding
        case home
    }
}

final class InitialScreenManager {
    @Inject var authenticationManager: AuthenticationManagerType

    @Published private(set) var state: State = .splashScreen

    @Published private var initialLoadingInProgress: Bool = true

    private var cancellables: Cancellables = .init()

    func getCurrentScreenState() -> State {
        guard !initialLoadingInProgress else {
            return .splashScreen
        }
        if authenticationManager.isUserLoggedIn {
            return .home
        } else {
            return .onboarding
        }
    }

    func update(state: State) {
        self.state = state
    }

    func finishInitialLoading() {
        initialLoadingInProgress = false
    }
}
