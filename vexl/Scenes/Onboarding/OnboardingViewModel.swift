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
        case tapped
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
            return "import your friends anonymously."
        case .buyAndSell:
            return "see their buy & sell offers."
        case .requestIdentity:
            return "request identity for the ones you like and trade."
        }
    }

    var buttonTitle: String {
        switch presentationState {
        case .friends, .buyAndSell:
            return "Next"
        case .requestIdentity:
            return "Got it!"
        }
    }

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .showLogin:
                    self.route.send(.tapped)
                case .next:
                    self.selectedIndex += 1
                }
            })
            .store(in: cancelBag)
    }
}
