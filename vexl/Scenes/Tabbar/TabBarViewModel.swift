//
//  TabBarViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 10/05/22.
//

import Foundation
import Cleevio
import Combine

final class TabBarViewModel: ViewModelType {
    @Inject private var cryptocurrencyManager: CryptocurrencyValueManagerType
    @Inject private var syncInboxManager: SyncInboxManagerType
    @Inject private var deeplinkManager: DeeplinkManagerType
    @Inject private var reencryptionManager: ReencryptionManagerType
    let notificationViewModel = NotificationViewModel()

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case didAppear
    }

    let action: ActionSubject<UserAction> = .init()
    let goToInboxTab = PassthroughSubject<Void, Never>()

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        cryptocurrencyManager.startPollingCoinData()
        cryptocurrencyManager.fetchChart(option: cryptocurrencyManager.currentTimeline.value)
        syncInboxManager.startSyncingInboxes()
        setupBindings()
        setupActions()
    }

    func checkSelectedTab() {
        if deeplinkManager.shouldGoToInboxOnStartup {
            goToInboxTab.send()
            deeplinkManager.cleanState()
        }
    }

    func checkIfNotificationsAreEnabled() {
        notificationViewModel.checkIfNotificationsAreEnabled()
    }

    private func setupBindings() {
        deeplinkManager.goToInboxTab
            .subscribe(goToInboxTab)
            .store(in: cancelBag)
    }

    private func setupActions() {
        action
            .filter { $0 == .didAppear}
            .asVoid()
            .sink { [reencryptionManager] in
                reencryptionManager.synchronizeContacts()
                reencryptionManager.synchronizeGroups()
            }
            .store(in: cancelBag)
    }
}
