//
//  RequestAccessPhoneContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 15/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class RequestAccessPhoneContactsViewModel: RequestAccessContactsViewModel {

    override var title: String {
        L.registerPhoneContactsTitle()
    }

    override var subtitle: String {
        L.registerPhoneContactsSubtitle()
    }

    override var importButton: String {
        L.registerContactsImportButton()
    }

    override var displaySkipButton: Bool {
        false
    }

    override var image: Data? {
        R.image.onboarding.importPhone()?.jpegData(compressionQuality: 1)
    }

    // MARK: - phone actions

    var contactsImported: ActionSubject<Void> = .init()

    override init(activity: Activity) {
        super.init(activity: activity)
        setupBindings()
    }

    private func setupBindings() {
        accessConfirmed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .completed
            }
            .store(in: cancelBag)

        completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .initial
                owner.contactsImported.send(())
            }
            .store(in: cancelBag)
    }

    // Here we don't need to do anything special on the rest of the states apart from initial
    // because the Authorization request it's being handle else where.
    // The rest of the cases are used for Facebook import
    override func advanceCurrentState() {
        switch currentState {
        case .initial:
            currentState = .completed
        case .requestAccess, .accessConfirmed, .completed:
            break
        }
    }

    override func cancelCurrentState() {
        switch currentState {
        case .initial, .requestAccess, .accessConfirmed, .completed:
            currentState = .initial
        }
    }
}
