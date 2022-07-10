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

    @Inject var offerService: OfferServiceType
    @Inject var chatService: ChatServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var inboxManager: InboxManagerType
    @Inject var chatRepository: ChatRepositoryType

    enum ImageSource {
        case photoAlbum, camera
    }

    enum Modal {
        case none
        case friends
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
    @Published var messages: [ChatConversationSection] = []

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
        case showOfferTapped(offer: Offer?)
        case showDeleteTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let username: String = Constants.randomName
    let avatar: UIImage? = nil
    let friends: [ChatCommonFriendViewData] = [.stub, .stub, .stub]
    let offerType: OfferType?
    var offer: Offer?
    var imageSource = ImageSource.photoAlbum

    var offerLabel: String {
        offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("")
    }

    var isModalPresented: Bool {
        modal != .none
    }

    var offerViewData: OfferDetailViewData? {
        guard let offer = offer else { return nil }
        return OfferDetailViewData(offer: offer, isRequested: false)
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

    private let inboxKeys: ECCKeys
    private let receiverPublicKey: String
    private let isBlocked = false

    init(inboxKeys: ECCKeys, receiverPublicKey: String, offerType: OfferType?) {
        self.inboxKeys = inboxKeys
        self.receiverPublicKey = receiverPublicKey
        self.offerType = offerType
        setupActionBindings()
        setupChatInputBindings()
        setupChatImageInputBindings()
        setupRevealIdentityRequestBindings()
        setupRevealIdentityResponseBindings()
        setupBlockChatBindings()
        setupDeleteChatBindings()
        setupModalPresentationBindings()
        setupInboxManagerBinding()
        setupOfferBindings()
    }

    private func setupInboxManagerBinding() {
        chatService
            .getStoredChatMessages(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: receiverPublicKey)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, messages in
                owner.showChatMessages(messages)
            }
            .store(in: cancelBag)

        inboxManager
            .completedSyncing
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case let .success(messages):
                    let messagesForInbox = messages.filter {
                        $0.inboxKey == owner.inboxKeys.publicKey && $0.contactInboxKey == owner.receiverPublicKey
                    }
                    owner.showChatMessages(messagesForInbox)
                case .failure:
                    // TODO: - show some alert
                    break
                }
            }
            .store(in: cancelBag)
    }

    private func setupOfferBindings() {
        offerService
            .getStoredOffers()
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .compactMap { owner, offers -> Offer? in
                offers.first { $0.offerPublicKey == owner.inboxKeys.publicKey }
            }
            .withUnretained(self)
            .sink { owner, offer in
                owner.offer = offer
            }
            .store(in: cancelBag)
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
            .compactMap { owner, image -> ParsedChatMessage? in
                ParsedChatMessage
                    .createMessage(text: owner.currentMessage,
                                   image: image,
                                   inboxPublicKey: owner.inboxKeys.publicKey,
                                   contactInboxKey: owner.receiverPublicKey)
            }

        inputMessage
            .withUnretained(self)
            .flatMap { owner, message in
                owner.sendMessage(type: .message, parsedMessage: message)
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.messages.appendItem(.createInput(text: owner.currentMessage,
                                                       image: owner.selectedImage?.base64EncodedString))
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

        chatRepository
            .dismissAction
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupRevealIdentityRequestBindings() {
        sharedChatAction
            .filter { $0 == .revealIdentity }
            .map { _ -> Modal in .identityRevealRequest }
            .assign(to: &$modal)
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
            .map { _ -> Route in .showDeleteTapped }
            .subscribe(route)
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
    }

    private func setupModalPresentationBindings() {
        sharedAction
            .filter { $0 == .dismissModal }
            .withUnretained(self)
            .map { _ -> Modal in .none }
            .assign(to: &$modal)

        sharedChatAction
            .withUnretained(self)
            .filter { owner, action in
                action == .showOffer && owner.offer != nil
            }
            .map { owner, _ -> Route in .showOfferTapped(offer: owner.offer) }
            .subscribe(route)
            .store(in: cancelBag)

        sharedChatAction
            .filter { $0 == .commonFriends }
            .map { _ -> Modal in .friends }
            .assign(to: &$modal)
    }

    private func sendMessage(type: MessageType, parsedMessage: ParsedChatMessage?) -> AnyPublisher<Void, Never> {
        if let parsedMessage = parsedMessage, let message = parsedMessage.asString {
            return chatService.sendMessage(inboxKeys: inboxKeys,
                                           receiverPublicKey: receiverPublicKey,
                                           message: message,
                                           messageType: type)
                .track(activity: primaryActivity)
                .materialize()
                .compactMap(\.value)
                .flatMapLatest(with: self) { owner, _ in
                    owner.chatService.saveParsedMessages([parsedMessage], inboxKeys: owner.inboxKeys)
                        .track(activity: owner.primaryActivity)
                        .materialize()
                        .compactMap(\.value)
                }
                .flatMapLatest(with: self) { owner, _ in
                    owner.inboxManager.updateInboxMessages()
                        .materialize()
                        .compactMap(\.value)
                }
                .asVoid()
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .eraseToAnyPublisher()
        }
    }

    private func showChatMessages(_ messages: [ParsedChatMessage]) {
        let conversationItems = messages.map { message -> ChatConversationItem in
            var itemType: ChatConversationItem.ItemType

            switch message.contentType {
            case .text:
                itemType = .text
            case .image:
                itemType = .image
            case .communicationRequestResponse:
                itemType = .start
            case .anonymousRequest:
                itemType = .sendReveal
            case .anonymousRequestResponse:
                itemType = .receiveReveal
            case .deleteChat, .communicationRequest, .none:
                itemType = .noContent
            }

            return ChatConversationItem(type: itemType,
                                        isContact: message.isFromContact,
                                        text: message.text,
                                        image: message.image)
        }
        let conversationSection = ChatConversationSection(date: Date(),
                                                          messages: conversationItems)
        self.messages.append(conversationSection)
    }

    func deleteMessages() {
        chatRepository
            .deleteChat(inboxKeys: inboxKeys, contactPublicKey: receiverPublicKey)
            .sink()
            .store(in: cancelBag)
    }
}
