//
//  InboxViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import SwiftUI
import Cleevio
import Combine

final class InboxViewModel: ViewModelType, ObservableObject {

    // MARK: - Dependency Bindings

    @Inject var inboxManager: InboxManagerType
    @Inject var remoteConfigManager: RemoteConfigManagerType

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
        case buyTap
        case sellTap
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
        case buyTapped
        case sellTapped
    }

    var route: CoordinatingSubject<Route> = .init()
    var requestImageName: String {
        hasPendingRequests ? R.image.chat.request.name : R.image.chat.requestEmpty.name
    }
    var isMarketplaceLocked: Bool {
        remoteConfigManager.getBoolValue(for: .isMarketplaceLocked)
    }
    // MARK: - Variables

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    /// This variable is used for bypassing a bug that causes latest chat messages to not update.
    /// The bug is caused when fetched `chats` publisher emits a new value. we create a new array of view models that gets assigned to `inboxItems` replacing the old view models.
    /// For some weird reson the SwiftUI updates the UI correctly (e.g. reorders them) but doesn't update the reference to the cells `data` model, which gets deallocated and stops updating its fields.
    /// Solution for this is to hold strong reference for the old view models and not release them.
    private var inboxItemStrongReference: [InboxItem] = .init()

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
            .withUnretained(self)
            .sink(receiveValue: { owner, items in
                owner.inboxItemStrongReference.append(contentsOf: items)
                withAnimation {
                    owner.inboxItems = items
                }
            })
            .store(in: cancelBag)

        $isRefreshing
            .filter { $0 }
            .withUnretained(self)
            .sink { owner, _ in
                owner.inboxManager.userRequestedSync()
            }
            .store(in: cancelBag)

        inboxManager
            .didFinishSyncing
            .withUnretained(self)
            .filter { $0.0.isRefreshing }
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

        action
            .filter { $0 == .buyTap }
            .map { _ -> Route in .buyTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .sellTap }
            .map { _ -> Route in .sellTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
