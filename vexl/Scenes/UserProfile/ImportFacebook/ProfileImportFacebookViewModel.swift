//
//  ProfileImportFacebookViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 24/07/22.
//

import Foundation
import Cleevio

final class ProfileImportFacebookViewModel: ImportContactsViewModel {

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

        @Inject var facebookManager: FacebookManagerType

        guard let facebookId = facebookManager.facebookID,
              let facebookToken = facebookManager.facebookToken else {
                  throw UserError.fetchFacebookFriends
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
