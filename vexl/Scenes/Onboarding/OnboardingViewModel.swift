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
        case skip
        case next
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var selectedIndex = 0

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case tapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .skip:
                    self.route.send(.tapped)
                case .next:
                    self.selectedIndex += 1
                }
            })
            .store(in: cancelBag)
    }
}
