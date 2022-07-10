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
    }

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case messageSend
        case cameraTap
        case dismissModal
        case deleteTap
        case blockTap
        case blockConfirmedTap
        case revealResponseTap
        case revealResponseConfirmationTap
        case deleteImageTap
        case expandImageTap(groupId: String, messageId: String)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentMessage: String = ""
    @Published var selectedImage: Data?
    @Published var messages: [ChatConversationSection] = []

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showImagePicker = false
    @Published var showImagePickerActionSheet = false
    @Published var modal = Modal.none
    @Published var username: String = Constants.randomName
    @Published var avatar: Data?

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
        case showRevealIdentityTapped
        case showRevealIdentityResponseTapped
        case showRevealIdentityModal(isUserResponse: Bool, username: String, avatar: String?)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

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
        selectedImage
    }

    private let cancelBag: CancelBag = .init()

    private var sharedAction: AnyPublisher<UserAction, Never> {
        action
            .share()
            .eraseToAnyPublisher()
    }

    private var isInputValid: Bool {
        !currentMessage.isEmpty || selectedImage != nil
    }

    var chatActionViewModel = ChatActionViewModel()
    var userIsRevealed = false
    private let inboxKeys: ECCKeys
    private let receiverPublicKey: String
    private let isBlocked = false

    init(inboxKeys: ECCKeys, receiverPublicKey: String, offerType: OfferType?) {
        self.inboxKeys = inboxKeys
        self.receiverPublicKey = receiverPublicKey
        self.offerType = offerType
        setupActionBindings()
        setupUpdateUIBindings()
        setupChatInputBindings()
        setupChatImageInputBindings()
        setupRevealIdentityResponseBindings()
        setupModalPresentationBindings()
        setupInboxManagerBinding()
        setupOfferBindings()

        chatActionViewModel
            .route
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupUpdateUIBindings() {
        chatRepository
            .getContactIdentity(inboxKeys: inboxKeys, contactPublicKey: receiverPublicKey)
            .withUnretained(self)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, user in
                owner.updateContactInformation(username: user.name, avatar: user.image)
            })
            .store(in: cancelBag)

        chatService
            .getStoredChatMessages(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: receiverPublicKey)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, messages in
                owner.showChatMessages(messages, filter: [])
            }
            .store(in: cancelBag)
    }

    private func setupInboxManagerBinding() {
        inboxManager
            .completedSyncing
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case let .success(messages):
                    let messagesForInbox = messages.filter {
                        $0.inboxKey == owner.inboxKeys.publicKey && $0.contactInboxKey == owner.receiverPublicKey
                    }
                    owner.showChatMessages(messagesForInbox, filter: [.revealRejected, .revealApproval])
                    owner.updateRevealedUser(messages: messages)
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
                offers.first { $0.offerPublicKey == owner.inboxKeys.publicKey || $0.offerPublicKey == owner.receiverPublicKey }
            }
            .withUnretained(self)
            .sink { owner, offer in
                owner.offer = offer
                owner.chatActionViewModel.offer = offer
            }
            .store(in: cancelBag)
    }

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
                owner.chatRepository
                    .sendMessage(inboxKeys: owner.inboxKeys,
                                 receiverPublicKey: owner.receiverPublicKey,
                                 type: .message,
                                 parsedMessage: message,
                                 updateInbox: true)
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.messages.appendItem(.createInput(text: owner.currentMessage,
                                                       image: owner.selectedImage?.base64EncodedString()))
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

    private func setupRevealIdentityResponseBindings() {
        sharedAction
            .filter { $0 == .revealResponseTap }
            .map { _ -> Route in .showRevealIdentityResponseTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupModalPresentationBindings() {
        sharedAction
            .filter { $0 == .dismissModal }
            .withUnretained(self)
            .map { _ -> Modal in .none }
            .assign(to: &$modal)
    }

    private func updateRevealedUser(messages: [ParsedChatMessage]) {
        if let revealMessage = messages.first(where: { $0.messageType == .revealApproval }),
           let user = revealMessage.user {
            updateContactInformation(username: user.name, avatar: user.image)
            updateDisplayedRevealMessages(isAccepted: true, user: user)
            route.send(.showRevealIdentityModal(isUserResponse: false, username: user.name, avatar: user.image))
        } else if messages.contains(where: { $0.messageType == .revealRejected }) {
            updateDisplayedRevealMessages(isAccepted: false, user: nil)
        }
    }

    private func showChatMessages(_ messages: [ParsedChatMessage], filter: [MessageType]) {
        let conversationItems = messages.compactMap { message -> ChatConversationItem? in

            guard !filter.contains(message.messageType) else {
                return nil
            }

            var itemType: ChatConversationItem.ItemType

            switch message.contentType {
            case .text:
                itemType = .text
            case .image:
                itemType = .image
            case .communicationRequestResponse:
                itemType = .start
            case .anonymousRequest:
                itemType = message.isFromContact ? .receiveIdentityReveal : .requestIdentityReveal
            case .anonymousRequestResponse:
                itemType = message.messageType == .revealApproval ? .approveIdentityReveal : .rejectIdentityReveal
            case .deleteChat, .communicationRequest, .none:
                itemType = .noContent
            }

            return ChatConversationItem(type: itemType,
                                        isContact: message.isFromContact,
                                        text: message.text,
                                        image: message.image)
        }
        self.messages.appendItems(conversationItems)
    }

    func deleteMessages() {
        chatRepository
            .deleteChat(inboxKeys: inboxKeys, contactPublicKey: receiverPublicKey)
            .track(activity: primaryActivity)
            .sink()
            .store(in: cancelBag)
    }

    func requestIdentityReveal() {
        chatRepository
            .requestIdentityReveal(inboxKeys: inboxKeys, contactPublicKey: receiverPublicKey)
            .track(activity: primaryActivity)
            .withUnretained(self)
            .sink { owner, _ in
                owner.messages.appendItem(.createIdentityRequest())
            }
            .store(in: cancelBag)
    }

    func identityRevealResponse(isAccepted: Bool) {
        chatRepository
            .identityRevealResponse(inboxKeys: inboxKeys, contactPublicKey: receiverPublicKey, isAccepted: isAccepted)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<ParsedChatMessage.ChatUser?, Never> in
                if isAccepted {
                    return owner.chatRepository
                        .getContactIdentity(inboxKeys: owner.inboxKeys, contactPublicKey: owner.receiverPublicKey)
                        .materialize()
                        .compactMap { $0.value }
                        .eraseToAnyPublisher()
                } else {
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, user in
                if let user = user, isAccepted {
                    owner.updateContactInformation(username: user.name, avatar: user.image)
                    owner.route.send(.showRevealIdentityModal(isUserResponse: true, username: user.name, avatar: user.image))
                }

                owner.updateDisplayedRevealMessages(isAccepted: isAccepted, user: user)
            })
            .store(in: cancelBag)
    }

    private func updateDisplayedRevealMessages(isAccepted: Bool, user: ParsedChatMessage.ChatUser?) {
        if let user = user, isAccepted {
            messages.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: user)
        } else {
            messages.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: user)
        }
    }

    private func updateContactInformation(username: String, avatar: String?) {
        self.username = username
        self.avatar = avatar?.dataFromBase64
        self.userIsRevealed = true
        self.chatActionViewModel.userIsRevealed = true
    }
}
