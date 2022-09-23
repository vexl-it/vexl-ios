//
//  LockAppViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 23/09/22.
//

import Foundation
import Cleevio
import Combine

final class LockAppViewModel: ViewModelType {

    enum Style {
        case update, maintenance
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case updateTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    var largeTitle: String {
        L.generalAppName()
    }
    var title: String {
        switch style {
        case .update:
            return L.forceUpdateTitle()
        case .maintenance:
            return L.lockMaintenanceTitle()
        }
    }
    var subtitle: String {
        switch style {
        case .update:
            return L.forceUpdateSubtitle()
        case .maintenance:
            return L.lockMaintenanceSubtitle()
        }
    }
    var image: String {
        switch style {
        case .update:
            return R.image.lockApp.update.name
        case .maintenance:
            return R.image.lockApp.maintenance.name
        }
    }
    var showAction: Bool {
        switch style {
        case .update:
            return true
        case .maintenance:
            return false
        }
    }
    var showOverlay: Bool {
        switch style {
        case .update:
            return false
        case .maintenance:
            return true
        }
    }
    var actionTitle: String {
        L.forceUpdateButton()
    }

    private var style: Style
    private let cancelBag: CancelBag = .init()

    init(style: Style) {
        self.style = style
        setupBindings()
    }

    private func setupBindings() {
        action
            .filter { $0 == .updateTap }
            .sink { _ in
                print("123123123")
            }
            .store(in: cancelBag)
    }
}
