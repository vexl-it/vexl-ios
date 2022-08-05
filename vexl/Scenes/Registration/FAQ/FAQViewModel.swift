//
//  FAQViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 4/08/22.
//

import Foundation
import Cleevio
import Combine

final class FAQViewModel: ViewModelType, ObservableObject {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
        case backTap
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentIndex = 0
    @Published var primaryActivity: Activity = .init()
    @Published var hasAgreedTermsAndConditions = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var content: [FAQContent] = FAQContent.content
    var route: CoordinatingSubject<Route> = .init()

    var title: String {
        FAQContent.content[currentIndex].title
    }
    var description: NSAttributedString {
        FAQContent.content[currentIndex].attributedDescription
    }

    var nextButtonTitle: String {
        if currentIndex == content.count - 1 {
            return "Continue"
        } else {
            return "Next"
        }
    }
    var backButtonTitle: String {
        if currentIndex == 0 {
            return "Close"
        } else {
            return "Back"
        }
    }

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        action
            .filter { $0 == .nextTap }
            .withUnretained(self)
            .sink { owner, _ in
                if owner.currentIndex < owner.content.count - 1 {
                    owner.currentIndex += 1
                } else {
                    owner.route.send(.continueTapped)
                }
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .backTap }
            .withUnretained(self)
            .sink { owner, _ in
                if owner.currentIndex > 0 {
                    owner.currentIndex -= 1
                } else {
                    owner.route.send(.continueTapped)
                }
            }
            .store(in: cancelBag)
    }
}
