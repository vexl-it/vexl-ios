//
//  ImportFacebookContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 30/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

class ImportFacebookContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() {

        guard let facebookId = authenticationManager.currentUser?.facebookId,
              let facebookToken = authenticationManager.currentUser?.facebookToken else {
                  return
              }

        let facebookContacts = contactsManager
            .fetchFacebookContacts(id: facebookId, accessToken: facebookToken)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)

        facebookContacts
            .map { $0.map { $0.id } }
            .withUnretained(self)
            .flatMap { owner, contactIds in

                // Fetch facebook friends that can be imported/have not been imported to the Backend

                owner.contactsManager
                    .getActiveFacebookContacts(contactIds, withId: facebookId, token: facebookToken)
                    .track(activity: owner.primaryActivity)
                    .materialize()
            }
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, availableContacts in
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}
