//
//  InboxViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio
import Combine

final class InboxViewModel: ViewModelType, ObservableObject {

    // MARK: - Dependency Bindings

    @Inject var inboxManager: InboxManagerType
    @Inject var chatService: ChatServiceType

    // MARK: - Persistence Bindings

    // TODO: fetch only chats that conforms to 'isApproved == true' and sort them by date last message date
    @Fetched(
        fetchImmediately: false,
        sortDescriptors: [ NSSortDescriptor(key: "lastMessageDate", ascending: false) ]
    )
    var chats: [ManagedChat]

    @Fetched(predicate: NSPredicate(format: "isRequesting == true AND isApproved == false"))
    var requests: [ManagedChat]

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case selectFilter(option: InboxFilterOption)
        case continueTap
        case requestTap
        case selectMessage(id: String)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var filter: InboxFilterOption = .all
    @Published var primaryActivity: Activity = .init()

    @Published var hasPendingRequests = false
    @Published var inboxItems: [InboxItem] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestTapped
        case conversationTapped(inboxKeys: ECCKeys, recieverPublicKey: String, offerType: OfferType?)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupActionBindings()
        setupInboxBindings()
        setupRequestBindings()
        action.send(.selectFilter(option: .all))
    }

    private func setupRequestBindings() {
        $requests.publisher
            .map(\.objects.count)
            .map { $0 > 0 }
            .assign(to: &$hasPendingRequests)
    }

    private func setupInboxBindings() {
        $chats.publisher
            .map(\.objects)
            .map { $0.map(InboxItem.init) }
            .assign(to: &$inboxItems)
    }

    private func setupActionBindings() {

        let action = action
            .share()

        action
            .filter { $0 == .requestTap }
            .map { _ -> Route in .requestTapped }
            .subscribe(route)
            .store(in: cancelBag)

        self.action
            .compactMap { action -> InboxFilterOption? in
                if case let .selectFilter(option) = action { return option }
                return nil
            }
            .withUnretained(self)
            .sink { owner, filter in
                var predicate = NSPredicate(format: "isRequesting == false AND isApproved == true")
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, filter.chatPredicate].compactMap { $0 })
                owner.$chats.load(predicate: predicate)
            }
            .store(in: cancelBag)

        action
            .compactMap { action -> String? in
                if case let .selectMessage(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, id in
                guard let index = owner.inboxItems.firstIndex(where: { $0.id == id }),
                      index < owner.inboxManager.currentInboxMessages.count else {
                    return
                }
                let chatInboxMessage = owner.inboxManager.currentInboxMessages[index]
                let offerType = owner.inboxItems[index].offerType
                owner.route.send(.conversationTapped(inboxKeys: chatInboxMessage.inbox,
                                                     recieverPublicKey: chatInboxMessage.contactInbox,
                                                     offerType: offerType))
            })
            .store(in: cancelBag)
    }
}
