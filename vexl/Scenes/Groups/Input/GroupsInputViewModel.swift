//
//  GroupsInputViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio
import Combine

final class GroupsInputViewModel: ViewModelType, ObservableObject {

    @Inject var groupManager: GroupManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var groupCode: String

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case continueTapped
    }

    let fromDeeplink: Bool
    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var isCodeValid: Bool {
        groupCode.count == 6
    }
    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init(code: String?, fromDeeplink: Bool) {
        self.groupCode = code ?? ""
        self.fromDeeplink = fromDeeplink
        setupActions()
    }

    private func setupActions() {
        let action = action.share()

        action
            .filter { $0 == .continueTap }
            .asVoid()
            .withUnretained(self)
            .map(\.groupCode)
            .compactMap(Int.init)
            .flatMap { [groupManager, primaryActivity] code in
                groupManager
                    .joinGroup(code: code)
                    .track(activity: primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .map { _ -> Route in .continueTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
