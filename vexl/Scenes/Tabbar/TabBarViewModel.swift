//
//  TabBarViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 10/05/22.
//

import Foundation
import Cleevio

final class TabBarViewModel: ViewModelType {

    @Inject var cryptocurrencyManager: CryptocurrencyValueManagerType
    @Inject var syncInboxManager: SyncInboxManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
    }

    let action: ActionSubject<UserAction> = .init()

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        cryptocurrencyManager.startFetchingCurrency(every: Constants.bitcoinPollInterval)
        syncInboxManager.startSyncingInboxes(every: Constants.inboxSyncPollInterval)
    }
}
