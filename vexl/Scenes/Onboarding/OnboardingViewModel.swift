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

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedIndex = OnboardingView.PresentationState.friends.rawValue

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case skipTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    var numberOfPages: Int {
        OnboardingView.PresentationState.allCases.count
    }

    var presentationState: OnboardingView.PresentationState {
        OnboardingView.PresentationState(rawValue: selectedIndex) ?? .friends
    }

    var isLastOnboardingPage: Bool {
        selectedIndex < numberOfPages - 1
    }

    var title: String {
        switch presentationState {
        case .friends:
            return L.onboardingIntroMessageFriend()
        case .buyAndSell:
            return L.onboardingIntroMessageBuySell()
        case .requestIdentity:
            return L.onboardingIntroMessageRequest()
        }
    }

    var buttonTitle: String {
        switch presentationState {
        case .friends, .buyAndSell:
            return L.next()
        case .requestIdentity:
            return L.gotIt()
        }
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
