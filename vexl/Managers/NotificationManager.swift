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
    func handleNotification(of type: NotificationType?, with userInfo: [AnyHashable: Any], completionHandler: ((Error?) -> Void)?)

    func requestToken()
}

final class NotificationManager: NSObject, NotificationManagerType {

    @Inject var groupManager: GroupManagerType
    @Inject var inboxManager: InboxManagerType
    @Inject var offerManager: OfferManagerType
    @Inject var deeplinkManager: DeeplinkManagerType

    private var fcmTokenValue: CurrentValueSubject<String?, Never> = .init(nil)
    private var authorisationStatus: CurrentValueSubject<UNAuthorizationStatus?, Never> = .init(nil)
    // swiftlint:disable discouraged_optional_boolean
    private var notificationHandled: Bool?

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
        defer { notificationHandled = nil }
        let userInfo = response.notification.request.content.userInfo
        let typeRawValue: String? = userInfo["type"] as? String

        guard let type: NotificationType = typeRawValue.flatMap(NotificationType.init) else { return }

        log.debug("Notification received with following data \(userInfo)")

        if notificationHandled == nil {
            log.debug("Notification wasn't handled in foreground")
            handleNotification(of: type, with: userInfo, completionHandler: nil)
        }

        handleDeeplink(of: type, with: userInfo)

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        defer { notificationHandled = true }

        let typeRawValue: String? = notification.request.content.userInfo["type"] as? String
        let type: NotificationType? = typeRawValue.flatMap(NotificationType.init)

        handleNotification(of: type, with: notification.request.content.userInfo, completionHandler: nil)

        var presentationOptions: UNNotificationPresentationOptions = []

        if #available(iOS 14, *) {
            presentationOptions = [.list, .banner, .badge, .sound]
        } else {
            presentationOptions = [.alert, .badge, .sound]
        }

        if type == .groupNewMember || type == .newAppUser {
            presentationOptions = []
        }

        completionHandler(presentationOptions)
    }

    func handleNotification(of type: NotificationType?, with userInfo: [AnyHashable: Any], completionHandler: ((Error?) -> Void)?) {
        switch type {
        case .message, .requestReveal, .approveReveal, .disapproveReveal, .requestMessaging, .approveMessaging, .disaproveMessaging, .deleteChat:
            if let inboxPK = userInfo["inbox"] as? String {
                inboxManager.syncInbox(with: inboxPK, completionHandler: completionHandler)
            }
        case .groupNewMember:
            if let groupUUID = userInfo["group_uuid"] as? String {
                groupManager.updateOffersForNewMembers(groupUUID: groupUUID, completionHandler: completionHandler)
            }
        case .newAppUser:
            if let publicKey = userInfo["public_key"] as? String {
                offerManager.syncUserOffers(withPublicKeys: [publicKey], completionHandler: completionHandler)
            }
        case .none:
            break
        }
    }

    private func handleDeeplink(of type: NotificationType?, with userInfo: [AnyHashable: Any]) {
        switch type {
        case .message, .requestReveal, .approveReveal, .disapproveReveal, .approveMessaging:
            if let inboxPK = userInfo["inbox"] as? String, let senderPK = userInfo["sender"] as? String {
                deeplinkManager.handleDeeplink(with: .openChat(inboxPK: inboxPK, senderPK: senderPK))
            }
        case .requestMessaging, .disaproveMessaging:
            deeplinkManager.handleDeeplink(with: .openRequest)
        default:
            break
        }
    }
}

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        log.debug("Receiving firebase token: \(fcmToken ?? "nil")")
        fcmTokenValue.send(fcmToken)
    }
}
