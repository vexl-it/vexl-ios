//
//  SyncInboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 23/06/22.
//

import Foundation
import Combine
import Cleevio

protocol SyncInboxManagerType {
    func startSyncingInboxes()
    func stopSyncingInboxes()
}

final class SyncInboxManager: SyncInboxManagerType {

    @Inject private var inboxManager: InboxManagerType
    @Inject private var notificationManager: NotificationManagerType

    private var cancellable: AnyCancellable?
    private let cancelBag: CancelBag = .init()

    func startSyncingInboxes() {
        stopSyncingInboxes()
        notificationManager.isRegisteredForNotifications
            .withUnretained(self)
            .sink { owner, isRegistered in
                if !isRegistered {
                    if owner.cancellable == nil {
                        owner.cancellable = Timer.publish(every: Constants.inboxSyncPollInterval, on: RunLoop.main, in: .default)
                            .autoconnect()
                            .withUnretained(owner)
                            .sink(receiveValue: { owner, _ in
                                owner.inboxManager.syncInboxes()
                            })
                    }
                } else {
                    owner.cancellable = nil
                }
            }
            .store(in: cancelBag)
    }

    func stopSyncingInboxes() {
        cancelBag.cancel()
        cancellable = nil
    }
}
