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

        guard let publicKey = authenticationManager.userKeys?.publicKey,
              let hash = authenticationManager.userFacebookHash else {
                  return
              }
        
        guard let facebookId = authenticationManager.currentUser?.facebookId,
              let facebookToken = authenticationManager.currentUser?.facebookToken else {
                  return
              }

        let facebookContacts = contactsService
            .createUser(withPublicKey: publicKey, hash: hash, forFacebook: true)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap { $0.value }
            .withUnretained(self)
            .flatMap { owner, _ in

                // Fetching facebook friends information using the SDK

                owner.contactsManager
                    .fetchFacebookContacts()
                    .track(activity: owner.primaryActivity)
                    .materialize()
            }
            .compactMap { $0.value }

        let inAppFacebookContacts = facebookContacts
            .withUnretained(self)
            .flatMap { owner, _ in

                // Fetch facebook friends that have/use the app from the Backend

                owner.contactsService
                    .getFacebookContacts(id: facebookId, accessToken: facebookToken)
                    .track(activity: owner.primaryActivity)
                    .materialize()
            }
            .compactMap { $0.value }

        inAppFacebookContacts
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
