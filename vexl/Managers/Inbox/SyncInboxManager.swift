//
//  SyncInboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 23/06/22.
//

import Foundation
import Combine

protocol SyncInboxManagerType {
    func startSyncingInboxes(every: TimeInterval)
    func stopSyncingInboxes()
}

final class SyncInboxManager: SyncInboxManagerType {

    @Inject private var inboxManager: InboxManagerType
    private var cancellable: AnyCancellable?

    func startSyncingInboxes(every interval: TimeInterval) {
        cancellable = Timer.publish(every: interval, on: RunLoop.main, in: .default)
            .autoconnect()
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                print("SYNCING INBOXES")
                owner.inboxManager.syncInboxes()
            })
    }

    func stopSyncingInboxes() {
        cancellable = nil
    }
}
