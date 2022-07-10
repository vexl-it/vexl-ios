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

    @Published var currentState: ViewState = .loading
    @Published var items: [ContactInformation] = []
    @Published var searchText = ""
    @Published var hasSelectedItem = false

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

    private var selectedItems: [ContactInformation] {
        items.filter { $0.isSelected }
    }

    private var canBeCompletedWithoutSelection: Bool {
        (currentState == .content && !hasSelectedItem) || currentState == .loading || currentState == .empty
    }

    var actionTitle: String {
        if hasSelectedItem {
            return currentState == .success ? L.registerPhoneCodeInputSuccess() : L.registerContactsImportButton()
        } else {
            return L.continue()
        }
    }

    let cancelBag: CancelBag = .init()

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
        action
            .filter { action in
                ![UserAction.unselectAll, .importContacts].contains(action)
            }
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
            .filter { $0 == .unselectAll }
            .withUnretained(self)
            .sink { owner, _ in
                owner.unselectAllItems()
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .importContacts }
            .withUnretained(self)
            .filter { $0.0.canBeCompletedWithoutSelection }
            .sink { owner, _ in
                owner.completed.send(())
            }
            .store(in: cancelBag)
    }

    private func setupImportAction() {
        let hashContacts = action
            .withUnretained(self)
            .filter { $0.0.currentState == .content && $0.0.hasSelectedItem && $0.1 == .importContacts }
            .map(\.0.selectedItems)
            .withUnretained(self)
            .flatMap { owner, contacts in
                owner.hashContacts(contacts: contacts)
                    .eraseToAnyPublisher()
            }
            .share()
            .eraseToAnyPublisher()

        let importContact = hashContacts
            .withUnretained(self)
            .flatMap { owner, contacts in
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
            .flatMap { owner, contacts in
                owner.contactsRepository.save(contacts: contacts)
            }

        Publishers.Zip(importContact, saveContacts)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if response.0.imported {
                    owner.currentState = .success
                }
            })
            .filter { $0.0.currentState == .success }
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, _ in
                owner.completed.send(())
            })
            .store(in: cancelBag)
    }

    private func hashContacts(contacts: [ContactInformation]) -> AnyPublisher<[(ContactInformation, String)], Error> {
        let phoneNumber = Formatters.phoneNumberFormatter
        let countryCode = phoneNumber.countryCode(for: Locale.current.regionCode ?? "")
        return contacts
            .publisher
            .withUnretained(self)
            .flatMap { owner, contact -> AnyPublisher<(ContactInformation, String), Error> in
                let identifier = contact.sourceIdentifier
                let trimmedIdentifier = identifier.removeWhitespaces()
                let formattedIdentifier: String = {
                    if let countryCode = countryCode, !trimmedIdentifier.contains("+") {
                        return "\(countryCode)\(trimmedIdentifier)"
                    }
                    return trimmedIdentifier
                }()
                return owner.cryptoService
                    .hashHMAC(password: Constants.contactsHashingPassword, message: formattedIdentifier)
                    .map { hash in (contact, hash) }
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()
    }

    private func select(_ isSelected: Bool, item: ContactInformation) {
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

    func fetchContacts() throws {
        fatalError("Must implement fetch contacts")
    }
}
