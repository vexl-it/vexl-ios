//
//  ChatViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class ChatViewModel: ViewModelType, ObservableObject {

    @Inject var chatService: ChatServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var inboxManager: InboxManagerType

    enum ImageSource {
        case photoAlbum, camera
    }

    enum Modal {
        case none
        case offer
        case friends
        case delete
        case deleteConfirmation
        case block
        case blockConfirmation
        case identityRevealRequest
        case identityRevealConfirmation
    }

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case chatActionTap(action: ChatAction)
        case messageSend
        case cameraTap
        case dismissModal
        case deleteTap
        case deleteConfirmedTap
        case blockTap
        case blockConfirmedTap
        case revealRequestConfirmationTap
        case revealResponseTap
        case revealResponseConfirmationTap
        case deleteImageTap
        case expandImageTap(groupId: String, messageId: String)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentMessage: String = ""
    @Published var selectedImage: UIImage?

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showImagePicker = false
    @Published var showImagePickerActionSheet = false
    @Published var modal = Modal.none

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case expandImageTapped(image: Data)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let username: String = Constants.randomName
    let avatar: UIImage? = nil
    let friends: [ChatCommonFriendViewData] = [.stub, .stub, .stub]
    let offerType: OfferType = .buy
    var messages: [ChatConversationSection] = ChatConversationSection.stub
    var imageSource = ImageSource.photoAlbum

    var offerLabel: String {
        offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("")
    }

    var isModalPresented: Bool {
        modal != .none
    }

    var selectedImageData: Data? {
        selectedImage?.jpegData(compressionQuality: 1)
    }

    private let cancelBag: CancelBag = .init()

    private var sharedAction: AnyPublisher<UserAction, Never> {
        action
            .share()
            .eraseToAnyPublisher()
    }
    private var sharedChatAction: AnyPublisher<ChatAction, Never> {
        action
            .compactMap { action -> ChatAction? in
                if case let .chatActionTap(chatAction) = action { return chatAction }
                return nil
            }
            .share()
            .eraseToAnyPublisher()
    }

    private var isInputValid: Bool {
        !currentMessage.isEmpty || selectedImage != nil
    }

    // TODO: - Pass real keys from the inbox + local storage service

    private let inboxKeys: ECCKeys = ECCKeys() // offer key
    private let senderKeys: ECCKeys = ECCKeys() // user key
    private let receiverPublicKey: String = "" // user who is having the conversation with
    private let isBlocked = false

    init() {
        setupActionBindings()
        setupChatInputBindings()
        setupChatImageInputBindings()
        setupRevealIdentityRequestBindings()
        setupRevealIdentityResponseBindings()
        setupBlockChatBindings()
        setupDeleteChatBindings()
        setupModalPresentationBindings()
    }

    // TODO: - Add post messages to the BE when tapping send/requests

    private func setupChatImageInputBindings() {
        sharedAction
            .filter { $0 == .cameraTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.showImagePickerActionSheet = true
            }
            .store(in: cancelBag)

        sharedAction
            .filter { $0 == .deleteImageTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.selectedImage = nil
            }
            .store(in: cancelBag)

        sharedAction
            .compactMap { action -> (groupId: String, messageId: String)? in
                if case let .expandImageTap(groupId, messageId) = action { return (groupId: groupId, messageId: messageId) }
                return nil
            }
            .withUnretained(self)
            .compactMap { owner, ids -> Data? in
                guard let messageGroup = owner.messages.first(where: { $0.id.uuidString == ids.groupId }),
                      let message = messageGroup.messages.first(where: { $0.id.uuidString == ids.messageId }) else {
                          return nil
                      }
                return message.image
            }
            .map { image -> Route in .expandImageTapped(image: image) }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupChatInputBindings() {
        let inputMessage = sharedAction
            .withUnretained(self)
            .filter { $0.1 == .messageSend && $0.0.isInputValid }
            .flatMap { owner, _ -> AnyPublisher<String?, Never> in
                guard let selectedImage = owner.selectedImage else { return Just<String?>(nil).eraseToAnyPublisher() }
                return selectedImage.base64Publisher
                    .track(activity: owner.primaryActivity)
            }
            .withUnretained(self)
            .compactMap { owner, image -> String? in
                ParsedChatMessage
                    .createMessage(text: owner.currentMessage,
                                   image: image,
                                   inboxPublicKey: owner.inboxKeys.publicKey)?
                    .asString
            }

        inputMessage
            .withUnretained(self)
            .flatMap { owner, message in
                owner.sendMessage(type: .message, message: message)
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.messages.appendItem(.createInput(text: owner.currentMessage,
                                                       image: owner.selectedImage?.jpegData(compressionQuality: 1),
                                                       previewImage: owner.selectedImage?.jpegData(compressionQuality: 0.25)))
                owner.selectedImage = nil
                owner.currentMessage = ""
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        sharedAction
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupRevealIdentityRequestBindings() {
        sharedChatAction
            .filter { $0 == .revealIdentity }
            .map { _ -> Modal in .identityRevealRequest }
            .assign(to: &$modal)

        let requestConfirmed = sharedAction
            .filter { $0 == .revealRequestConfirmationTap }
            .withUnretained(self)
            .compactMap { owner, _ -> String? in
                ParsedChatMessage
                    .createIdentityRequest(inboxPublicKey: owner.inboxKeys.publicKey)?
                    .asString
            }

        requestConfirmed
            .withUnretained(self)
            .flatMap { owner, message in
                owner.sendMessage(type: .revealRequest, message: message)
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.messages.appendItem(.createIdentityRequest())
                owner.modal = .none
                owner.currentMessage = ""
            }
            .store(in: cancelBag)
    }

    private func setupRevealIdentityResponseBindings() {
        sharedAction
            .filter { $0 == .revealResponseTap }
            .map { _ -> Modal in .identityRevealConfirmation }
            .assign(to: &$modal)

        sharedAction
            .filter { $0 == .revealResponseConfirmationTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.modal = .none
            }
            .store(in: cancelBag)
    }

    private func setupDeleteChatBindings() {
        sharedChatAction
            .filter { $0 == .deleteChat }
            .map { _ -> Modal in .delete }
            .assign(to: &$modal)

        sharedAction
            .filter { $0 == .deleteTap }
            .map { _ -> Modal in .deleteConfirmation }
            .assign(to: &$modal)

        let deleteMessages = sharedAction
            .filter { $0 == .deleteConfirmedTap }
            .withUnretained(self)
            .compactMap { owner, _ -> String? in
                ParsedChatMessage
                    .createDelete(inboxPublicKey: owner.inboxKeys.publicKey)?
                    .asString
            }

        deleteMessages
            .withUnretained(self)
            .flatMap { owner, message in
                owner.sendMessage(type: .deleteChat, message: message)
            }
            .withUnretained(self)
            .sink { owner, _ in
                // TODO: - remove all the information locally
                owner.modal = .none
            }
            .store(in: cancelBag)
    }

    private func setupBlockChatBindings() {
        sharedChatAction
            .filter { $0 == .blockUser }
            .map { _ -> Modal in .block }
            .assign(to: &$modal)

        sharedAction
            .filter { $0 == .blockTap }
            .map { _ -> Modal in .blockConfirmation }
            .assign(to: &$modal)

        let signature = sharedAction
            .filter { $0 == .blockConfirmedTap }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.chatService.requestChallenge(publicKey: owner.senderKeys.publicKey)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .flatMap { owner, challenge in
                owner.cryptoService.signECDSA(keys: owner.senderKeys, message: challenge.challenge)
            }

        signature
            .withUnretained(self)
            .flatMap { owner, signature in
                owner.chatService.blockInbox(inboxPublicKey: owner.senderKeys.publicKey,
                                             publicKeyToBlock: owner.receiverPublicKey,
                                             signature: signature,
                                             isBlocked: owner.isBlocked)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .asVoid()
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, _ in
                owner.modal = .none
            })
            .store(in: cancelBag)
    }

    private func setupModalPresentationBindings() {
        sharedAction
            .filter { $0 == .dismissModal }
            .withUnretained(self)
            .map { _ -> Modal in .none }
            .assign(to: &$modal)

        sharedChatAction
            .filter { $0 == .showOffer }
            .map { _ -> Modal in .offer }
            .assign(to: &$modal)

        sharedChatAction
            .filter { $0 == .commonFriends }
            .map { _ -> Modal in .friends }
            .assign(to: &$modal)
    }

    private func sendMessage(type: MessageType, message: String) -> AnyPublisher<Void, Never> {
        chatService.sendMessage(inboxPublicKey: inboxKeys.publicKey,
                                senderPublicKey: senderKeys.publicKey,
                                receiverPublicKey: receiverPublicKey,
                                message: message,
                                messageType: type)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .asVoid()
            .eraseToAnyPublisher()
    }
}
