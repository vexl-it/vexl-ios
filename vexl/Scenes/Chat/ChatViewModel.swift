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

    @Inject var inboxManager: InboxManagerType
    @Inject var chatManager: ChatManagerType
    @Inject var contactsRepository: ContactsRepositoryType

    enum ImageSource {
        case photoAlbum, camera
    }

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case messageSend
        case cameraTap
        case dismissModal
        case deleteImageTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentMessage: String = ""
    @Published var selectedImage: Data?
    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showImagePicker = false
    @Published var showImagePickerActionSheet = false
    @Published var username: String = L.generalAnonymous()
    @Published var avatar: Data?

    var errorIndicator: ErrorIndicator { primaryActivity.error }
    var activityIndicator: ActivityIndicator { primaryActivity.indicator }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case expandImageTapped(image: Data)
        case showOfferTapped(offer: ManagedOffer?)
        case showDeleteTapped
        case showRevealIdentityTapped
        case showRevealIdentityResponseTapped
        case showRevealIdentityModal(isUserResponse: Bool, username: String, avatar: String?)
        case showBlockTapped
        case showCommonFriendsTapped
        case showCommonFriendsModal(contacts: [ManagedContact])
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let friends: [ChatCommonFriendViewData] = [.stub, .stub, .stub]
    lazy var offer: ManagedOffer? = chat.receiverKeyPair?.offer
    var imageSource = ImageSource.photoAlbum
    var offerLabel: String { offer?.type == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("") }
    var offerViewData: OfferDetailViewData? { offer.flatMap(OfferDetailViewData.init) }
    var selectedImageData: Data? { selectedImage }

    private let cancelBag: CancelBag = .init()
    private lazy var sharedAction: AnyPublisher<UserAction, Never> = action.share().eraseToAnyPublisher()
    private var isInputValid: Bool { !currentMessage.isEmpty || selectedImage != nil }
    private var chat: ManagedChat

    var chatActionViewModel: ChatActionViewModel
    var chatConversationViewModel: ChatConversationViewModel
    @Published var userIsRevealed = false

    init(chat: ManagedChat) {
        self.chat = chat
        self.chatActionViewModel = ChatActionViewModel(chat: chat)
        self.chatConversationViewModel = ChatConversationViewModel(chat: chat)

        setupChildViewModelBindings()
        setupActionBindings()
        setupUpdateUIBindings()
        setupChatInputBindings()
        setupChatImageInputBindings()
    }

    private func setupChildViewModelBindings() {
        chatActionViewModel
            .route
            .filter { $0 != .showCommonFriendsTapped }
            .subscribe(route)
            .store(in: cancelBag)

        chatActionViewModel
            .route
            .filter { $0 == .showCommonFriendsTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<[ManagedContact], Never> in
                let commonFriends = owner.offer?.commonFriends ?? []
                return owner.contactsRepository
                    .getCommonFriends(hashes: commonFriends)
                    .track(activity: owner.primaryActivity)
                    .eraseToAnyPublisher()
            }
            .map { contacts -> Route in .showCommonFriendsModal(contacts: contacts) }
            .subscribe(route)
            .store(in: cancelBag)

        chatConversationViewModel
            .displayExpandedImage
            .map { image -> Route in .expandImageTapped(image: image) }
            .subscribe(route)
            .store(in: cancelBag)

        chatConversationViewModel
            .identityRevealResponseTap
            .map { _ -> Route in .showRevealIdentityResponseTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func setupUpdateUIBindings() {
        let profile = chat.receiverKeyPair?.profile

        profile?.publisher(for: \.avatarData).map { _ in profile?.avatar }.assign(to: &$avatar)
        profile?.publisher(for: \.name).filterNil().assign(to: &$username)
        chat.publisher(for: \.isRevealed).assign(to: &$userIsRevealed)
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
    }

    private func setupChatInputBindings() {
        let inputMessage = sharedAction
            .withUnretained(self)
            .filter { $0.1 == .messageSend && $0.0.isInputValid }
            .flatMap { owner, _ -> AnyPublisher<String?, Never> in
                guard let selectedImage = owner.selectedImage else { return Just<String?>(nil).eraseToAnyPublisher() }
                return selectedImage.base64Publisher
                    .track(activity: owner.primaryActivity)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let payload = inputMessage
            .withUnretained(self)
            .compactMap { (owner, image: String?) -> MessagePayload? in
                MessagePayload
                    .createMessage(text: owner.currentMessage,
                                   image: image,
                                   inboxPublicKey: owner.chat.inbox?.keyPair?.publicKey,
                                   contactInboxKey: owner.chat.receiverKeyPair?.publicKey)
            }

        payload
            .withUnretained(self)
            .flatMap { owner, payload in
                owner.chatManager
                    .send(payload: payload, chat: owner.chat)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, _ in
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

        // TODO: dismiss on delete ManagedObject
    }

    func deleteMessages() {
        chatManager
            .delete(chat: chat)
            .track(activity: primaryActivity)
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    func requestIdentityReveal() {
        chatManager
            .requestIdentity(chat: chat)
            .track(activity: primaryActivity)
            .sink()
            .store(in: cancelBag)
    }

    func identityRevealResponse(isAccepted: Bool) {
        chatManager
            .identityResponse(allow: isAccepted, chat: chat)
            .track(activity: primaryActivity)
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                guard let name = owner.chat.receiverKeyPair?.profile?.name else {
                    return
                }

                owner.route.send(.showRevealIdentityModal(isUserResponse: true,
                                                          username: name,
                                                          avatar: owner.chat.receiverKeyPair?.profile?.avatar?.base64EncodedString()))
            })
            .store(in: cancelBag)
    }

    func blockMessages() {
        chatManager
            .setBlockMessaging(isBlocked: !chatActionViewModel.isChatBlocked, chat: chat)
            .track(activity: primaryActivity)
            .withUnretained(self)
            .sink(receiveValue: { owner in
                owner.chatActionViewModel.isChatBlocked.toggle()
            })
            .store(in: cancelBag)
    }
}
