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
    @Inject private var notificationManager: NotificationManagerType
    @Inject private var refreshManager: RefreshManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case didAppear
        case didLoad
    }

    let action: ActionSubject<UserAction> = .init()
    let goToInboxTab = PassthroughSubject<Void, Never>()

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showNotifications
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private var notificationsChecked = false
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
        guard !notificationsChecked else { return }
        notificationsChecked = true
        switch notificationManager.currentStatus {
        case .denied, .notDetermined:
            route.send(.showNotifications)
        default:
            break
        }
    }

    private func setupBindings() {
        deeplinkManager.goToInboxTab
            .subscribe(goToInboxTab)
            .store(in: cancelBag)
    }

    private func setupActions() {
        action
            .filter { $0 == .didLoad }
            .asVoid()
            .flatMap { [refreshManager] in
                refreshManager
                    .refresh()
                    .catch { _ in Just(()) }
            }
            .sink { [reencryptionManager] in
                reencryptionManager.synchronizeContacts()
                reencryptionManager.synchronizeGroups()
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .didAppear }
            .withUnretained(self)
            .sink { owner, _ in
                owner.checkSelectedTab()
                owner.checkIfNotificationsAreEnabled()
            }
            .store(in: cancelBag)
    }
}
