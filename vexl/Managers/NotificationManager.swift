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

protocol NotificationManagerType {
    var notificationToken: AnyPublisher<String, Never> { get }
    var isRegisteredForNotifications: AnyPublisher<Bool, Never> { get }

    func requestToken()
}

final class NotificationManager: NSObject, NotificationManagerType {

    @Inject var inboxManager: InboxManagerType

    private var fcmTokenValue: CurrentValueSubject<String?, Never> = .init(nil)

    var isRegisteredForNotifications: AnyPublisher<Bool, Never> {
        Just(UIApplication.shared.isRegisteredForRemoteNotifications).eraseToAnyPublisher()
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
            updateTokens()
        }
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }

    func requestToken() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            DispatchQueue.main.async { [weak self] in
                self?.updateTokens()
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    private func updateTokens() {
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().token { [weak self] token, _ in
            if let token = token {
                print("[NOTIFICATIONS] loaded fcm token: \(token)")
                self?.fcmTokenValue.send(token)
            }
        }
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

        if let inboxPK = notification.request.content.userInfo["inbox"] as? String {
            inboxManager.syncInbox(with: inboxPK)
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
        print("[NOTIFICATIONS] received fcm token: \(fcmToken)")
        fcmTokenValue.send(fcmToken)
    }
}
