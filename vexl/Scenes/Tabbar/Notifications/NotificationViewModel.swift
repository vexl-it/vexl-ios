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

    enum Route: Equatable {
        case showNotifications
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private var notificationsChecked = false
    private let cancelBag: CancelBag = .init()

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
        .flatMap { owner, token in
            owner.contactsService.updateUser(token: token)
        }
        .sink()
        .store(in: cancelBag)
    }
}
