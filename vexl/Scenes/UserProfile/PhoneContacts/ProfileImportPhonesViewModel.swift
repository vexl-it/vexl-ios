//
//  ProfileImportPhonesViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 24/07/22.
//

import Foundation
import Cleevio
import Combine

final class ProfileImportPhonesViewModel: ImportContactsViewModel {

    override var actionTitle: String {
        L.registerContactsUpdateButton()
    }

    override var shouldSelectAll: Bool {
        true
    }

    override var previousSelectedContacts: [ContactInformation] {
        alreadySelectedContacts
    }

    private var alreadySelectedContacts: [ContactInformation] = []

    override init() {
        super.init()
        showActionButton = false
        showBackButton = true
        currentState = .loading
        setupActionBindings()
    }

    private func setupActionBindings() {
        $hasSelectedItem
            .withUnretained(self)
            .sink { owner, hasSelection in
                owner.showActionButton = hasSelection
            }
            .store(in: cancelBag)
    }

    override func fetchContacts() throws {
        @Inject var encryptionService: EncryptionServiceType

        Just(())
            .withUnretained(self)
            .flatMap { owner in
                owner.contactsManager
                    .fetchPhoneContacts()
                    .track(activity: owner.primaryActivity)
            }
            .withUnretained(self)
            .flatMap { owner, contacts in
                encryptionService
                    .hashContacts(contacts: contacts)
                    .track(activity: owner.primaryActivity)
            }
            .withUnretained(self)
            .flatMap { owner, hashedPhones in
                owner.contactsManager
                    .getUserPhoneContacts(hashedPhones.map(\.1))
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, contacts in
                owner.currentState = contacts.isEmpty ? .empty : .content
                owner.items = contacts
                owner.alreadySelectedContacts = contacts
                    .filter { $0.isSelected }

                for contact in contacts {
                    owner.select(contact.isSelected, item: contact)
                }
            }
            .store(in: cancelBag)
    }
}
