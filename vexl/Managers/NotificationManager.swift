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

enum NotificationKey: String {
    case inboxPublicKey = "inbox"
    case senderPublicKey = "sender"
    case groupUUID = "group_uuid"
    case publicKey = "public_key"
    case notificationType = "type"
    case connectionLevel = "connection_level"
}

protocol NotificationManagerType {
    var currentStatus: UNAuthorizationStatus { get }
    var statusPublisher: AnyPublisher<UNAuthorizationStatus, Never> { get }
    var notificationToken: AnyPublisher<String, Never> { get }
    var isRegisteredForNotifications: AnyPublisher<Bool, Never> { get }
    func handleNotification(of type: NotificationType?, with userInfo: [AnyHashable: Any], completionHandler: ((Error?) -> Void)?)

    func requestToken()
    func refreshStatus()
}

final class NotificationManager: NSObject, NotificationManagerType {

    @Inject var groupManager: GroupManagerType
    @Inject var inboxManager: InboxManagerType
    @Inject var contactsService: ContactsServiceType
    @Inject var offerManager: OfferManagerType
    @Inject var deeplinkManager: DeeplinkManagerType
    @Inject var logManager: LogManagerType

    private var fcmTokenValue: CurrentValueSubject<String?, Never> = .init(nil)
    private var authorisationStatus: CurrentValueSubject<UNAuthorizationStatus?, Never> = .init(nil)
    // swiftlint:disable discouraged_optional_boolean
    private var notificationHandled: Bool?

    @UserDefault(.notificationToken, defaultValue: nil)
    private var cachedToken: String?

    var currentStatus: UNAuthorizationStatus {
        authorisationStatus.value ?? .notDetermined
    }

    var statusPublisher: AnyPublisher<UNAuthorizationStatus, Never> {
        authorisationStatus
            .filterNil()
            .eraseToAnyPublisher()
    }

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
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        Publishers.CombineLatest(isRegisteredForNotifications, fcmTokenValue)
            .filter { $0.0 }
            .map(\.1)
            .removeDuplicates()
            .filterNil()
            .filter { [weak self] token in
                token != self?.cachedToken
            }
            .flatMap { [contactsService] token in
                contactsService
                    .updateUser(token: token)
                    .materialize()
                    .compactMap(\.value)
                    .map { _ in token }
            }
            .flatMap { [inboxManager] token -> AnyPublisher<String, Never> in
                inboxManager
                    .updateNotificationToken(token: token)
                    .map { token }
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink { owner, token in
                owner.cachedToken = token
            }
            .store(in: cancelBag)

        refreshStatus()
    }

    func requestToken() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            guard let owner = self else {
                return
            }
            DispatchQueue.main.async {
                owner.refreshStatus()
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    func refreshStatus() {
        UIApplication.shared.registerForRemoteNotifications()

        Messaging.messaging().token { [weak self] token, _ in
            if let token = token {
                DispatchQueue.main.async {
                    self?.fcmTokenValue.send(token)
                }
            }
        }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.authorisationStatus.send(settings.authorizationStatus)
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { notificationHandled = nil }
        let userInfo = response.notification.request.content.userInfo
        let typeRawValue: String? = userInfo[NotificationKey.notificationType.rawValue] as? String

        guard let type: NotificationType = typeRawValue.flatMap(NotificationType.init) else { return }

        log.debug("Notification received with following data \(userInfo)")

        logManager.log(notification: type)

        if notificationHandled == nil {
            log.debug("Notification wasn't handled in foreground")
            handleNotification(of: type, with: userInfo)
        }

        handleDeeplink(of: type, with: userInfo)

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        defer { notificationHandled = true }

        let typeRawValue: String? = notification.request.content.userInfo[NotificationKey.notificationType.rawValue] as? String
        let type: NotificationType? = typeRawValue.flatMap(NotificationType.init)

        var presentationOptions: UNNotificationPresentationOptions = []

        if #available(iOS 14, *) {
            presentationOptions = [.list, .banner, .badge, .sound]
        } else {
            presentationOptions = [.alert, .badge, .sound]
        }

        if type == .groupNewMember || type == .newAppUser {
            presentationOptions = []
        }

        handleNotification(of: type, with: notification.request.content.userInfo) { _ in
            completionHandler(presentationOptions)
        }
    }

    func handleNotification(of type: NotificationType?, with userInfo: [AnyHashable: Any], completionHandler: ((Error?) -> Void)? = nil) {
        switch type {
        case .message, .requestReveal, .approveReveal, .disapproveReveal, .requestMessaging, .approveMessaging, .disaproveMessaging, .deleteChat:
            if let inboxPK = userInfo[NotificationKey.inboxPublicKey.rawValue] as? String {
                inboxManager.syncInbox(with: inboxPK, completionHandler: completionHandler)
            }
        case .groupNewMember:
            if let groupUUID = userInfo[NotificationKey.groupUUID.rawValue] as? String {
                groupManager.reencryptOffersForNewMembers(groupUUID: groupUUID, completionHandler: completionHandler)
            }
        case .newAppUser:
            if let publicKey = userInfo[NotificationKey.publicKey.rawValue] as? String,
               let friendDegreeRawValue = userInfo[NotificationKey.connectionLevel.rawValue] as? String,
               let friendDegree = OfferFriendDegree(rawValue: friendDegreeRawValue) {
                offerManager
                    .reencryptUserOffers(
                        withPublicKeys: [publicKey],
                        friendLevel: friendDegree,
                        completionHandler: completionHandler
                    )
            }
        case .none:
            completionHandler?(nil)
            break
        }
    }

    private func handleDeeplink(of type: NotificationType?, with userInfo: [AnyHashable: Any]) {
        switch type {
        case .message, .requestReveal, .approveReveal, .disapproveReveal, .approveMessaging:
            if let inboxPK = userInfo[NotificationKey.inboxPublicKey.rawValue] as? String,
               let senderPK = userInfo[NotificationKey.senderPublicKey.rawValue] as? String {
                deeplinkManager.handleDeeplink(with: .openChat(inboxPK: inboxPK, senderPK: senderPK))
            }
        case .requestMessaging, .disaproveMessaging:
            deeplinkManager.handleDeeplink(with: .openRequest)
        case .deleteChat:
            deeplinkManager.handleDeeplink(with: .openInbox)
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
