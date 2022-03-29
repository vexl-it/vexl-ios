//
//  RegisterContacts+ImportViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

class ImportContactsViewModel: ObservableObject {

    // MARK: - Dependencies

    @Inject var contactsManager: ContactsManager
    @Inject var contactsService: ContactsServiceType
    @Inject var authenticationManager: AuthenticationManager

    // MARK: - View State

    enum ViewState {
        case none
        case empty
        case content
        case success
    }

    // MARK: - Action Bindings

    enum UserAction: Equatable {
        case itemSelected(Bool, ImportContactItem)
        case unselectAll
        case importContacts

        static func == (lhs: UserAction, rhs: UserAction) -> Bool {
            switch (lhs, rhs) {
            case (.itemSelected, .itemSelected):
                return true
            case (.unselectAll, .unselectAll):
                return true
            case (.importContacts, .importContacts):
                return true
            default:
                return false
            }
        }
    }

    let action: ActionSubject<UserAction> = .init()
    let completed: ActionSubject<Void> = .init()

    // MARK: - View Bindings

    @Published var currentState: ViewState = .none
    @Published var items: [ImportContactItem] = []
    @Published var searchText = ""
    @Published var hasSelectedItem = false

    @Published var loading = false
    @Published var error: AlertError?

    var primaryActivity: Activity = .init()
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    // MARK: - Variables

    var filteredItems: [ImportContactItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.contains(searchText) }
    }
    
    private var selectedItems: [ImportContactItem] {
        return items
            .filter { $0.isSelected }
    }

    let cancelBag: CancelBag = .init()

    // MARK: - Init

    init() {
        setupActivity()
        setupActions()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .withUnretained(self)
            .sink { owner, error in
                owner.error = AlertError(error: error)
            }
            .store(in: cancelBag)
    }

    private func setupActions() {

        action
            .filter { action in
                switch action {
                case .itemSelected:
                    return true
                case .unselectAll, .importContacts:
                    return false
                }
            }
            .compactMap { action -> (Bool, ImportContactItem)? in
                if case let .itemSelected(isSelected, item) = action {
                    return (isSelected, item)
                }
                return nil
            }
            .withUnretained(self)
            .sink { owner, selection in
                owner.select(selection.0, item: selection.1)
            }
            .store(in: cancelBag)

        action
            .useAction(action: .unselectAll)
            .withUnretained(self)
            .sink { owner, _ in
                owner.unselectAllItems()
            }
            .store(in: cancelBag)

        let importContact = action
            .useAction(action: .importContacts)
            .withUnretained(self)
            .filter { $0.0.currentState == .content }
            .map { $0.0.selectedItems.map { $0.phone } }
            .withUnretained(self)
            .flatMap { owner, contacts in
                owner.contactsService
                    .importContacts(contacts)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }

        importContact
            .compactMap { $0.value }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if response.imported {
                    owner.currentState = .success
                }
            })
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .sink { owner, _ in
                owner.completed.send(())
            }
            .store(in: cancelBag)
    }

    private func select(_ isSelected: Bool, item: ImportContactItem) {
        guard let selectedIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[selectedIndex].isSelected = isSelected
        hasSelectedItem = items.contains(where: { $0.isSelected })
    }

    private func unselectAllItems() {
        for index in items.indices {
            items[index].isSelected = false
        }
        hasSelectedItem = false
    }

    func fetchContacts() {
        fatalError("Must implement fetch contacts")
    }
}

class PhoneImportContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() {
        let contacts = contactsManager.fetchPhoneContacts()
        let phones = contacts.map { $0.phone }

        contactsService
            .createUser(with: authenticationManager.userKeys?.publicKey ?? "", hash: authenticationManager.challengeValidation?.hash ?? "")
            .track(activity: primaryActivity)
            .materialize()
            .compactMap { $0.value }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.contactsService
                    .getAvailableContacts(phones)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap { $0.value }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink { owner, _ in
                let availableContacts = owner.contactsManager.availablePhoneContacts
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}

class FacebookImportContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() {
        let contacts = contactsManager.fetchPhoneContacts()
    }
}
