//
//  RequestAccessFacebookContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 15/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class RequestAccessFacebookContactsViewModel: RequestAccessContactsViewModel {

    override var title: String {
        L.registerFacebookContactsTitle()
    }

    override var subtitle: String {
        L.registerPhoneContactsSubtitle()
    }

    override var importButton: String {
        L.registerFacebookImportButton()
    }

    override var displaySkipButton: Bool {
        true
    }

    var contactsImported: ActionSubject<Result<Void, UserError>> = .init()

    override init(activity: Activity) {
        super.init(activity: activity)
        setupBindings()
    }

    private func setupBindings() {
        let loginFacebookUser = requestAccess
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.facebookManager
                    .loginWithFacebook(fromViewController: nil)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .compactMap { owner, response -> String? in
                guard let value = response.value, let facebookId = value else {
                    owner.currentState = .initial
                    return nil
                }
                return facebookId
            }

        loginFacebookUser
            .withUnretained(self)
            .flatMap { owner, facebookId in
                owner.userService
                    .facebookSignature(id: facebookId)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }
            .compactMap { $0.value }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if !response.challengeVerified {
                    owner.contactsImported.send(.failure(UserError.facebookValidation))
                } else {
                    owner.facebookManager.update(hash: response.hash, signature: response.signature)
                }
            })
            .filter(\.1.challengeVerified)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.contactsService
                    .createUser(forFacebook: true)
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
                owner.contactsImported.send(.success(()))
            }
            .store(in: cancelBag)
    }

    override func advanceCurrentState() {
        switch currentState {
        case .initial:
            currentState = .requestAccess
        case .requestAccess:
            currentState = .accessConfirmed
        case .accessConfirmed:
            currentState = .completed
        case .completed, .confirmRejection:
            currentState = .initial
        }
    }
}
