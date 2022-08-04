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

    // MARK: - Persistence Bindings

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
        case selectMessage(chat: ManagedChat)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var filter: InboxFilterOption = .all
    @Published var primaryActivity: Activity = .init()
    @Published var isRefreshing = false
    @Published var isGraphExpanded = false
    @Published var hasPendingRequests = false
    @Published var inboxItems: [InboxItem] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestTapped
        case conversationTapped(chat: ManagedChat)
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

        $isRefreshing
            .filter { $0 }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.inboxManager.syncInboxes()
            })
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: &$isRefreshing)
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
            .compactMap { action -> ManagedChat? in
                if case let .selectMessage(chat) = action { return chat }
                return nil
            }
            .map { Route.conversationTapped(chat: $0) }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, route in
                owner.route.send(route)
            })
            .sink()
            .store(in: cancelBag)
    }
}
