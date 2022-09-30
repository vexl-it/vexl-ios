//
//  NotificationPermissionViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.09.2022.
//

import Combine
import Cleevio

final class NotificationPermissionViewModel: ViewModelType {

    // MARK: - Dependencies

    @Inject var notificationManager: NotificationManagerType

    // MARK: - View State

    enum ViewState {
        case phoneInput
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case enableTap
        case close
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    var title: String {
        switch notificationManager.currentStatus {
        case .denied:
            return L.notificationsPermissionDisabledTitle()
        default:
            return L.notificationsPermissionTitle()
        }
    }

    var subtitle: String {
        switch notificationManager.currentStatus {
        case .denied:
            return L.notificationsPermissionDisabledSubtitle()
        default:
            return L.notificationsPermissionSubttile()
        }
    }

    var buttonTitle: String {
        switch notificationManager.currentStatus {
        case .denied:
            return L.notificationsPermissionDisabledButton()
        default:
            return L.notificationsPermissionEnable()
        }
    }

    // MARK: - Activities

    var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case showAreYouSureDialog
        case openSettings
        case continueTapped
        case closeTapped
    }

    var route: CoordinatingSubject<Route> = .init()
    private let cancelBag: CancelBag = .init()

    init() {
        setupBindings()
        setupActionBindings()
    }

    func rejectNotifications() {
        route.send(.continueTapped)
    }

    private func setupBindings() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.notificationManager.refreshStatus()
            })
            .store(in: cancelBag)

        notificationManager
            .statusPublisher
            .dropFirst()
            .compactMap { status -> Route? in
                switch status {
                case .authorized:
                    return .continueTapped
                case .denied:
                    return .showAreYouSureDialog
                default:
                    return nil
                }
            }
            .removeDuplicates()
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .withUnretained(self)
            .compactMap { owner, action -> Route? in
                switch action {
                case .enableTap:
                    switch owner.notificationManager.currentStatus {
                    case .notDetermined:
                        owner.notificationManager.requestToken()
                        return nil
                    case .authorized:
                        return .continueTapped
                    case .denied:
                        return .openSettings
                    default:
                        return nil
                    }
                case .close:
                    return .closeTapped
                }
            }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
