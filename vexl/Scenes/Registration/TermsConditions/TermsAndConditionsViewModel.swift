//
//  TermsAndConditionsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import Cleevio
import Combine

final class TermsAndConditionsViewModel: ViewModelType {

    enum Section: CaseIterable {
        case termsOfUse
        case policy

        var label: String {
            switch self {
            case .termsOfUse:
                return L.termsOfUseTermsBookmark()
            case .policy:
                return L.termsOfUsePolicyBookmark()
            }
        }
    }

    @Inject var notificationManager: NotificationManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case faqTap
        case dismissTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var hasAgreedTermsAndConditions = false
    @Published var currentSection: Section = .termsOfUse

    var currentContent: NSMutableAttributedString {
        switch currentSection {
        case .termsOfUse:
            return L.termsOfUseTerms().configureAttributedText(atributedMacros: FAQAttributedMacro.atributedMacros,
                                                               textStyle: .paragraphSemibold)
        case .policy:
            return L.termsOfUsePrivacy().configureAttributedText(atributedMacros: FAQAttributedMacro.atributedMacros,
                                                                 textStyle: .paragraphSemibold)
        }
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case faqTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        let action = action.share()

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .faqTap }
            .map { _ -> Route in .faqTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
