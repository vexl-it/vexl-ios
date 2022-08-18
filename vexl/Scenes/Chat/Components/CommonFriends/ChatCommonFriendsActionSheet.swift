//
//  ChatCommonFriendsActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 1/08/22.
//

import SwiftUI
import Combine
import Cleevio

final class ChatCommonFriendsSheetViewModel: BottomActionSheetViewModelProtocol {

    @Inject var contactService: ContactsServiceType
    @Inject var contactRepository: ContactsRepositoryType

    typealias CommonFriendBottomActionSheet = BottomActionSheet<ChatCommonFriendsActionSheetContent>

    var title: String = L.chatMessageCommonFriend()
    var primaryAction: CommonFriendBottomActionSheet.Action = .init(title: L.buttonGotIt(), isDismissAction: true)
    var secondaryAction: CommonFriendBottomActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: CommonFriendBottomActionSheet.ColorScheme = .main
    var content: ChatCommonFriendsActionSheetContent {
        ChatCommonFriendsActionSheetContent(friendsState: commonFriendsState)
    }

    @Published var commonFriendsState: ContentState<[ChatCommonFriendViewData]> = .loading

    private let cancelBag: CancelBag = .init()

    init(chat: ManagedChat, contacts: [ManagedContact]) {
        if let keyPair = chat.receiverKeyPair,
            let receiverPK = keyPair.publicKey,
            let offer = keyPair.offer,
            offer.user != nil {
            load(receiverPK: receiverPK)
        } else {
            commonFriendsState = .content(
                contacts.compactMap { contact in
                    guard let name = contact.name else {
                        return nil
                    }
                    return ChatCommonFriendViewData(
                        title: name,
                        subtitle: contact.phoneNumber,
                        avatar: contact.avatar
                    )
                }
            )
        }
    }

    func load(receiverPK: String) {
        contactService
            .getCommonFriends(publicKeys: [receiverPK])
            .map { $0[receiverPK] ?? [] }
            .flatMap { [contactRepository] hashes in
                contactRepository
                    .getCommonFriends(hashes: hashes)
            }
            .map { contacts -> [ChatCommonFriendViewData] in
                contacts.compactMap { contact in
                    guard let name = contact.name else {
                        return nil
                    }
                    return ChatCommonFriendViewData(
                        title: name,
                        subtitle: contact.phoneNumber,
                        avatar: contact.avatar
                    )
                }
            }
            .map { ContentState.content($0) }
            .catch { error in Just(.error(error)) }
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .withUnretained(self)
            .sink { owner, state in
                owner.commonFriendsState = state
            }
            .store(in: cancelBag)
    }
}

struct ChatCommonFriendsActionSheetContent: View {

    let friendsState: ContentState<[ChatCommonFriendViewData]>

    var body: some View {
        VStack(alignment: .center) {
            switch friendsState {
            case let .content(friends):
                if !friends.isEmpty {
                    ChatCommonFriendsView(friends: friends,
                                          dismiss: {})
                        .background(Appearance.Colors.gray6)
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                        .padding(.bottom, Appearance.GridGuide.point)
                } else {
                    Text(L.chatMessageCommonFriendEmpty())
                }
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .error:
                Text(L.generalInternalServerError())
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.35)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#if DEBUG || DEVEL
struct ChatCommonFriendsSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatCommonFriendsActionSheetContent(friendsState: .content([.stub, .stub]))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
