//
//  NotificationManager.swift
//  pilulka
//
//  Created by Adam Salih on 13.10.2021.
//

import Foundation
import Combine
import UserNotifications
import FirebaseMessaging
import Cleevio

enum NotificationType: String {
    case message = "MESSAGE"
    case requestReveal = "REQUEST_REVEAL"
    case approveReveal = "APPROVE_REVEAL"
    case disapproveReveal = "DISAPPROVE_REVEAL"
    case requestMessaging = "REQUEST_MESSAGING"
    case approveMessaging = "APPROVE_MESSAGING"
    case disaproveMessaging = "DISAPPROVE_MESSAGING"
    case deleteChat = "DELETE_CHAT"
    case groupNewMember = "GROUP_NEW_MEMBER"
    case newAppUser = "NEW_APP_USER"
}

protocol NotificationManagerType {
    var notificationToken: AnyPublisher<String, Never> { get }
    var isRegisteredForNotifications: AnyPublisher<Bool, Never> { get }

    func requestToken()
}

final class NotificationManager: NSObject, NotificationManagerType {

    @Inject var inboxManager: InboxManagerType

    private var fcmTokenValue: CurrentValueSubject<String?, Never> = .init(nil)
    private var authorisationStatus: CurrentValueSubject<UNAuthorizationStatus?, Never> = .init(nil)

    var isRegisteredForNotifications: AnyPublisher<Bool, Never> {
        authorisationStatus
            .map { $0 == UNAuthorizationStatus.authorized }
            .eraseToAnyPublisher()
    }

    var notificationToken: AnyPublisher<String, Never> {
        isRegisteredForNotifications
            .filter { $0 }
            .asVoid()
            .withUnretained(self)
            .flatMap { $0.fcmTokenValue }
            .filterNil()
            .eraseToAnyPublisher()
    }

    private let cancelBag: CancelBag = .init()

    override init() {
        super.init()
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            update()
        }
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }

    func requestToken() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            DispatchQueue.main.async { [weak self] in
                self?.update()
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    private func update() {
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().token { [weak self] token, _ in
            if let token = token {
                self?.fcmTokenValue.send(token)
            }
        }
        Future { promise in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                promise(.success(settings.authorizationStatus))
            }
        }
        .withUnretained(self)
        .sink { owner, status in
            owner.authorisationStatus.send(status)
        }
        .store(in: cancelBag)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let dict = response.notification.request.content.userInfo as? [String: Any] else { return }
        log.debug("Notification received with following data \(dict)")
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let type: NotificationType = .message
        switch type {
        case .message, .requestReveal, .approveReveal, .disapproveReveal, .requestMessaging, .approveMessaging, .disaproveMessaging, .deleteChat:
            if let inboxPK = notification.request.content.userInfo["inbox"] as? String {
                inboxManager.syncInbox(with: inboxPK)
            }
        case .groupNewMember:
            break
        case .newAppUser:
            break
        }

        var presentationOptions: UNNotificationPresentationOptions = []

        if #available(iOS 14, *) {
            presentationOptions = [.list, .banner, .badge, .sound]
        } else {
            presentationOptions = [.alert, .badge, .sound]
        }

        completionHandler(presentationOptions)
    }
}

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        fcmTokenValue.send(fcmToken)
    }
}
