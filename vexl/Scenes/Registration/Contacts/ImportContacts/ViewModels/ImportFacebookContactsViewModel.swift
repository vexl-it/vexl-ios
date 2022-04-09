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

//        let createFacebookUser = contactsService
//            .createUser(forFacebook: true)
//            .track(activity: primaryActivity)
//            .materialize()
//            .compactMap { $0.value }

        let facebookContacts = contactsService
            .getFacebookContacts(id: facebookId, accessToken: facebookToken)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap { $0.value }

        facebookContacts
            .withUnretained(self)
            .flatMap { owner, _ in

                // Fetch facebook friends that can be imported/have not been imported to the Backend

                owner.contactsService
                    .getAvailableFacebookContacts(id: facebookId, accessToken: facebookToken)
                    .track(activity: owner.primaryActivity)
                    .materialize()
            }
            .compactMap { $0.value }
            .withUnretained(self)
            .sink { owner, _ in
                let availableContacts = owner.contactsManager.availableFacebookContacts
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}
