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

        let contacts = contactsManager.fetchPhoneContacts()

        encryptionService.hashContacts(contacts: contacts)
            .track(activity: primaryActivity)
            .withUnretained(self)
            .flatMap { owner, hashedPhones in
                owner.contactsManager
                    .getActivePhoneContacts(hashedPhones.map(\.1))
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, availableContacts in
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}
