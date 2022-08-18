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

    @Inject var cryptocurrencyManager: CryptocurrencyValueManagerType
    @Inject var syncInboxManager: SyncInboxManagerType
    @Inject var deeplinkManager: DeeplinkManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
    }

    let action: ActionSubject<UserAction> = .init()

    var deeplinkIndex: AnyPublisher<Int, Never> {
        deeplinkManager
            .openDeeplink
            .map(\.tab.rawValue)
            .eraseToAnyPublisher()
    }

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

//    private let deeplinkIndexSubject = PassthroughSubject<
    private let cancelBag: CancelBag = .init()

    init() {
        cryptocurrencyManager.startPollingCoinData()
        cryptocurrencyManager.fetchChart(option: cryptocurrencyManager.currentTimeline.value)
        syncInboxManager.startSyncingInboxes()
    }
}
