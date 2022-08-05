//
//  ImportPhoneContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 30/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class ImportPhoneContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() throws {
        @Inject var encryptionService: EncryptionServiceType

        Just(())
            .withUnretained(self)
            .flatMap { owner in
                owner.contactsManager
                    .fetchPhoneContacts()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .flatMap { owner, contacts in
                encryptionService
                    .hashContacts(contacts: contacts)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
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
