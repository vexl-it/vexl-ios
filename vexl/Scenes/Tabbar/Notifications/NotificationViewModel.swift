//
//  NotificationViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.09.2022.
//

import Foundation
import Cleevio
import Combine

final class NotificationViewModel {
    @Inject private var notificationManager: NotificationManagerType
    @Inject private var contactsService: ContactsServiceType
    @Inject private var chatService: ChatServiceType
    @Inject private var userRepository: UserRepositoryType

    enum Route: Equatable {
        case showNotifications
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private var notificationsChecked = false
    private let cancelBag: CancelBag = .init()
    private var userTokenUpdateCancellable: AnyCancellable?
    private var inboxUpdateCancellable: AnyCancellable?

    init() {
        setupBindings()
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
        Publishers.CombineLatest(
            notificationManager.statusPublisher,
            notificationManager.notificationToken
        )
        .filter { data in
            let (status, token) = data
            return status == .authorized && !token.isEmpty
        }
        .map(\.1)
        .withUnretained(self)
        .sink(receiveValue: { owner, token in
            owner.updateToken(token: token)
        })
        .store(in: cancelBag)
    }

    private func updateToken(token: String) {
        userTokenUpdateCancellable?.cancel()
        userTokenUpdateCancellable = contactsService
            .updateUser(token: token)
            .sink()

        updateInboxesToken(token: token)
    }

    private func updateInboxesToken(token: String) {
        // This is a hotfix of a data race condition.
        // TODO: optimise follwing lines of code to make them run ideally in series
        for inbox in userRepository.getInboxes() {
            if let inboxKeys = inbox.keyPair?.keys {
                Just(())
                    .receive(on: DispatchQueue.main)
                    .flatMap { [chatService] in
                        chatService.updateInbox(eccKeys: inboxKeys, pushToken: token)
                    }
                    .sink()
                    .store(in: cancelBag)

            }
        }

    }
}
