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

class ImportPhoneContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() {
        let contacts = contactsManager.fetchPhoneContacts()
        let phones = contacts.map { $0.phone }

        contactsService
            .getAvailableContacts(phones)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap { $0.value }
            .eraseToAnyPublisher()
            .withUnretained(self)
            .sink { owner, _ in
                let availableContacts = owner.contactsManager.availablePhoneContacts
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}
