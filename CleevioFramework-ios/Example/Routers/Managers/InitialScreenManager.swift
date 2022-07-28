//
//  InitialScreenManager.swift
//  CleevioRoutersExample
//
//  Created by Thành Đỗ Long on 09.02.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
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
    @Inject var authenticationManager: AuthenticationManager

    @Published private(set) var state: State = .splashScreen

    @Published private var initialLoadingInProgress: Bool = true

    private var cancellables: Cancellables = .init()

    init() {
        setupSubscriptions()
    }

    func setupSubscriptions() {
        Publishers.CombineLatest($initialLoadingInProgress, authenticationManager.$authenticationState)
            .map { initialLoading, authState -> State in
                switch (initialLoading, authState) {
                case (true, _):
                    return .splashScreen
                case (_, .signedOut):
                    return .onboarding
                case (_, .signedIn):
                    return .home
                }
            }
            .assign(to: &$state)
    }

    func update(state: State) {
        self.state = state
    }

    func finishInitialLoading() {
        initialLoadingInProgress = false
    }
}
