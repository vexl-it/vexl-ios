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
        case welcome
        case registerName
        case registerContacts
        case home
    }

    enum OnboardingState: String {
        case initial
        case nameAndAvatar
        case importContacts
        case finished
    }
}

final class InitialScreenManager {
    @Inject var authenticationManager: AuthenticationManagerType
    @UserDefault(UserDefaultKey.onboardingState.rawValue, defaultValue: OnboardingState.initial.rawValue)
    private var _onboardingState: String

    private var onboardingState: OnboardingState {
        OnboardingState(rawValue: _onboardingState) ?? .initial
    }

    @Published private(set) var state: State = .splashScreen

    @Published private var initialLoadingInProgress: Bool = true

    private var cancellables: Cancellables = .init()

    func getCurrentScreenState() -> State {
        guard !initialLoadingInProgress else {
            return .splashScreen
        }

        switch onboardingState {
        case .initial:
            return .welcome
        case .nameAndAvatar:
            return .registerName
        case .importContacts:
            return .registerContacts
        case .finished:
            return authenticationManager.isUserLoggedIn ? .home : .welcome
        }
    }

    func update(state: State) {
        self.state = state
    }

    func update(onboardingState: OnboardingState) {
        self._onboardingState = onboardingState.rawValue
    }

    func finishInitialLoading() {
        initialLoadingInProgress = false
    }
}
