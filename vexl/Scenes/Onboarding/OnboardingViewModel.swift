//
//  OnboardingViewModel.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import UIKit
import SwiftUI
import Combine
import Cleevio

final class OnboardingViewModel: ViewModelType {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case showLogin
        case next
    }

    enum OnboardingState: Int, CaseIterable {
        case friends = 0
        case buyAndSell = 1
        case requestIdentity = 2

        var animation: LottieAnimation {
            switch self {
            case .friends:
                return .firstOnboarding
            case .buyAndSell:
                return .secondOnboarding
            case .requestIdentity:
                return .thirdOnboarding
            }
        }
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedIndex = OnboardingState.friends.rawValue

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case skipTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    var numberOfPages: Int {
        OnboardingState.allCases.count
    }

    var onboardingState: OnboardingState {
        OnboardingState(rawValue: selectedIndex) ?? .friends
    }

    var isLastOnboardingPage: Bool {
        selectedIndex < numberOfPages - 1
    }

    var title: String {
        switch onboardingState {
        case .friends:
            return L.introFirstTitle()
        case .buyAndSell:
            return L.introSecondTitle()
        case .requestIdentity:
            return L.introThirdTitle()
        }
    }

    var buttonTitle: String {
        L.continue()
    }

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        action
            .filter { $0 == .showLogin }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.skipTapped)
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .next }
            .withUnretained(self)
            .sink { owner, _ in
                owner.selectedIndex += 1
            }
            .store(in: cancelBag)
    }
}
