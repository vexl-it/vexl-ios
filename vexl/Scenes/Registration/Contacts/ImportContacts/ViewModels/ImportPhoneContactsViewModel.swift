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
    override func fetchContacts() {
        let contacts = contactsManager.fetchPhoneContacts()
        let phones = contacts.map(\.phone)

        contactsService
            .createUser()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.contactsManager
                    .getActivePhoneContacts(phones)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink { owner, availableContacts in
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}
