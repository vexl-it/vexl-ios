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

    @Inject var offerRepository: OfferRepositoryType
    @Inject var chatService: ChatServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var inboxManager: InboxManagerType
    @Inject var chatRepository: OldChatRepositoryType

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
        case showOfferTapped(offer: ManagedOffer?)
        case showDeleteTapped
        case showRevealIdentityTapped
        case showRevealIdentityResponseTapped
        case showRevealIdentityModal(isUserResponse: Bool, username: String, avatar: String?)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let friends: [ChatCommonFriendViewData] = [.stub, .stub, .stub]
    let offerType: OfferType?
    var offer: ManagedOffer?
    var imageSource = ImageSource.photoAlbum

    var offerLabel: String {
        offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("")
    }

    var offerViewData: OfferDetailViewData? {
        guard let offer = offer else { return nil }
        return OfferDetailViewData(offer: offer)
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

    var chatActionViewModel: ChatActionViewModel
    var chatConversationViewModel: ChatConversationViewModel
    var userIsRevealed = false
    private let inboxKeys: ECCKeys
    private let receiverPublicKey: String
    private let isBlocked = false

    init(inboxKeys: ECCKeys, receiverPublicKey: String, offerType: OfferType?) {
        self.inboxKeys = inboxKeys
        self.receiverPublicKey = receiverPublicKey
        self.offerType = offerType
        self.chatActionViewModel = ChatActionViewModel()
        self.chatConversationViewModel = ChatConversationViewModel(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey)
        setupChildViewModelBindings()
        setupActionBindings()
        setupUpdateUIBindings()
        setupChatInputBindings()
        setupChatImageInputBindings()
        setupOfferBindings()
    }

    private func setupChildViewModelBindings() {
        chatActionViewModel
            .route
            .subscribe(route)
            .store(in: cancelBag)

        chatConversationViewModel
            .updateContactInformation
            .withUnretained(self)
            .sink { owner, user in
                owner.updateContactInformation(username: user.name, avatar: user.image)
            }
            .store(in: cancelBag)

        chatConversationViewModel
            .displayExpandedImage
            .map { image -> Route in .expandImageTapped(image: image) }
            .subscribe(route)
            .store(in: cancelBag)

        chatConversationViewModel
            .identityRevealResponse
            .map { _ -> Route in .showRevealIdentityResponseTapped }
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
    }

    private func setupOfferBindings() {
        offerRepository
            .getOffer(with: inboxKeys.publicKey)
            .nilOnError()
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
                owner.chatConversationViewModel.addMessage(owner.currentMessage, image: owner.selectedImage)
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
                owner.chatConversationViewModel.addIdentityRequest()
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

                owner.chatConversationViewModel.updateDisplayedRevealMessages(isAccepted: isAccepted, user: user)
            })
            .store(in: cancelBag)
    }

    private func updateContactInformation(username: String, avatar: String?) {
        self.username = username
        self.avatar = avatar?.dataFromBase64
        self.userIsRevealed = true
        self.chatActionViewModel.userIsRevealed = true
        self.chatConversationViewModel.updateContact(name: username, avatar: avatar)
    }
}
