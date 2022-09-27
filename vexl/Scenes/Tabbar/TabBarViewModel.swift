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
    let notificationViewModel = NotificationViewModel()

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
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
}
