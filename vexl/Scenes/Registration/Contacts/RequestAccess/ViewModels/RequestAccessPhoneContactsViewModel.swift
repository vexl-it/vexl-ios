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

    // MARK: - phone actions

    var contactsImported: ActionSubject<Void> = .init()

    override init(username: String, avatar: Data?, activity: Activity) {
        super.init(username: username, avatar: avatar, activity: activity)
        setupBindings()
    }

    private func setupBindings() {
        accessConfirmed
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.contactsService
                    .createUser(forFacebook: false)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
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

    override func update(state: ViewState) {
        updateAlert(for: state)
        super.update(state: state)
    }

    override func advanceCurrentState() {
        switch currentState {
        case .initial:
            currentState = .requestAccess
        case .requestAccess, .confirmRejection:
            currentState = .accessConfirmed
        case .accessConfirmed:
            currentState = .completed
        case .completed:
            currentState = .initial
        }
    }

    override func cancelCurrentState() {
        switch currentState {
        case .initial, .confirmRejection, .accessConfirmed, .completed:
            currentState = .initial
        case .requestAccess:
            currentState = .confirmRejection
        }
    }

    private func updateAlert(for state: ViewState) {
        switch state {
        case .initial, .completed, .accessConfirmed:
            alert = nil
        case .requestAccess:
            alert = .request
        case .confirmRejection:
            alert = .reject
        }
    }
}
