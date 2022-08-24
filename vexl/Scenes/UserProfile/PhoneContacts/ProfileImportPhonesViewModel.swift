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
        showBackButton = true
        currentState = .loading
    }

    override func fetchContacts() throws {
        @Inject var encryptionService: EncryptionServiceType

        Just(())
            .withUnretained(self)
            .flatMap { owner in
                owner.contactsManager
                    .fetchPhoneContacts()
                    .track(activity: owner.primaryActivity)
                    .catch { _ in Just([]) }
            }
            .withUnretained(self)
            .flatMap { owner, contacts in
                encryptionService
                    .hashContacts(contacts: contacts)
                    .track(activity: owner.primaryActivity)
                    .catch { _ in Just([]) }
            }
            .withUnretained(self)
            .flatMap { owner, hashedPhones in
                owner.contactsManager
                    .getUserPhoneContacts(hashedPhones.map(\.1))
                    .track(activity: owner.primaryActivity)
                    .catch { _ in Just([]) }
            }
            .withUnretained(self)
            .sink { owner, contacts in
                owner.currentState = contacts.isEmpty ? .empty : .content
                owner.items = contacts
                for contact in contacts {
                    owner.select(contact.isSelected, item: contact)
                }
            }
            .store(in: cancelBag)
    }
}
