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

    @Inject var contactsRepository: ContactsRepositoryType
    @Inject var contactsManager: ContactsManagerType
    @Inject var facebookManager: FacebookManagerType
    @Inject var contactsService: ContactsServiceType
    @Inject var userService: UserServiceType
    @Inject var encryptionService: EncryptionServiceType
    @Inject var cryptoService: CryptoServiceType

    // MARK: - View State

    enum ViewState {
        case loading
        case empty
        case content
        case success
    }

    // MARK: - Action Bindings

    enum UserAction: Equatable {
        case itemSelected(Bool, ContactInformation)
        case importContacts
        case dismiss
        case searchActionTapped

        static func == (lhs: UserAction, rhs: UserAction) -> Bool {
            switch (lhs, rhs) {
            case (.itemSelected, .itemSelected):
                return true
            case (.importContacts, .importContacts):
                return true
            case (.dismiss, .dismiss):
                return true
            case (.searchActionTapped, .searchActionTapped):
                return true
            default:
                return false
            }
        }
    }

    let action: ActionSubject<UserAction> = .init()
    let completed: ActionSubject<Void> = .init()
    let dismiss: ActionSubject<Void> = .init()

    // MARK: - View Bindings

    @Published var currentState: ViewState = .loading
    @Published var items: [ContactInformation] = []
    @Published var searchText = ""
    @Published var hasSelectedItem = false

    @Published var showBackButton = false
    @Published var showActionButton = true

    @Published var loading = false
    @Published var error: Error?

    var primaryActivity: Activity = .init()
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    // MARK: - Variables

    var filteredItems: [ContactInformation] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.contains(searchText) }
    }

    var shouldSelectAll: Bool {
        false
    }

    var actionTitle: String {
        guard currentState != .empty else {
            return L.skip()
        }

        if hasSelectedItem {
            return currentState == .success ? L.registerPhoneCodeInputSuccess() : L.registerContactsImportButton()
        } else {
            return L.continue()
        }
    }

    var searchActionTitle: String {
        hasSelectedItem ? L.registerContactsImportDeselect() : L.registerContactsImportSelect()
    }

    let cancelBag: CancelBag = .init()

    private var newContacts: [ContactInformation] {
        items.filter { $0.isSelected && !$0.isStored }
    }

    private var removedContacts: [ContactInformation] {
        items.filter { !$0.isSelected && $0.isStored }
    }

    // MARK: - Init

    init() {
        setupActivity()
        setupActions()
        setupImportAction()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupActions() {
        let action = action.share()

        action
            .compactMap { action -> (Bool, ContactInformation)? in
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
            .filter { $0 == .searchActionTapped }
            .withUnretained(self)
            .sink { owner, _ in
                owner.selectAllItems(!owner.hasSelectedItem)
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismiss }
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss.send(())
            }
            .store(in: cancelBag)
    }

    private func setupImportAction() {
        let sharedAction = action
            .withUnretained(self)
            .filter { [.content, .empty].contains($0.0.currentState) && $0.0.loading.not && $0.1 == .importContacts }
            .share()

        let addNewContacts = sharedAction
            .map(\.0.newContacts)
            .withUnretained(self)
            .flatMap { owner, contacts -> AnyPublisher<Bool, Error> in
                owner.addNewContacts(contacts)
            }

        let removeContacts = sharedAction
            .map(\.0.removedContacts)
            .withUnretained(self)
            .flatMap { owner, contacts -> AnyPublisher<Bool, Error> in
                owner.removeContacts(contacts: contacts)
            }

        Publishers.Zip(addNewContacts, removeContacts)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                let (didImportContacts, didRemoveContacts) = response
                if didImportContacts && didRemoveContacts {
                    owner.currentState = .success
                }
            })
            .filter { $0.0.currentState == .success }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, _ in
                owner.completed.send(())
            })
            .store(in: cancelBag)
    }

    private func addNewContacts(_ contacts: [ContactInformation]) -> AnyPublisher<Bool, Error> {
        if contacts.isEmpty {
            return Just(true).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            let hashContacts = encryptionService
                .hashContacts(contacts: contacts)
                .share()
                .eraseToAnyPublisher()

            let importContact = hashContacts
                .withUnretained(self)
                .flatMap { owner, contacts -> AnyPublisher<ContactsImported, Never> in
                    owner.contactsService
                        .importContacts(contacts.map(\.1))
                        .track(activity: owner.primaryActivity)
                        .materialize()
                        .compactMap { $0.value }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()

            let saveContacts = hashContacts
                .withUnretained(self)
                .flatMap { owner, contacts -> AnyPublisher<[ManagedContact], Error> in
                    owner.contactsRepository.save(contacts: contacts)
                }

            return Publishers.Zip(importContact, saveContacts)
                .map(\.0.imported)
                .eraseToAnyPublisher()
        }
    }

    private func removeContacts(contacts: [ContactInformation]) -> AnyPublisher<Bool, Error> {
        if contacts.isEmpty {
            return Just(true).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            let hashContacts = encryptionService
                .hashContacts(contacts: contacts)
                .share()
                .eraseToAnyPublisher()

            let removeContacts = hashContacts
                .withUnretained(self)
                .flatMap { owner, contacts -> AnyPublisher<Void, Never> in
                    owner.contactsService
                        .removeContacts(contacts.map(\.1), fromFacebook: false)
                        .track(activity: owner.primaryActivity)
                        .materialize()
                        .compactMap { $0.value }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()

            let deleteContacts = hashContacts
                .withUnretained(self)
                .flatMap { owner, contacts -> AnyPublisher<Void, Error> in
                    owner.contactsRepository.delete(contacts: contacts)
                }

            return Publishers.Zip(removeContacts, deleteContacts)
                .map { _ in true }
                .eraseToAnyPublisher()
        }
    }

    func select(_ isSelected: Bool, item: ContactInformation) {
        guard let selectedIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[selectedIndex].isSelected = isSelected
        hasSelectedItem = items.contains(where: { $0.isSelected })
    }

    func selectAllItems(_ isSelected: Bool) {
        var items = self.items
        for index in items.indices {
            items[index].isSelected = isSelected
        }
        self.items = items
        hasSelectedItem = isSelected
    }

    func fetchContacts() throws {
        fatalError("Must implement fetch contacts")
    }
}
