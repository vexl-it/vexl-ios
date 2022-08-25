//
//  LoginViewModel.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import UIKit
import Combine
import Cleevio
import KeychainAccess

final class WelcomeViewModel: ViewModelType {

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var notificationManager: NotificationManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case continueTap
        case linkTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var hasAgreedTermsAndConditions = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
        case termsAndConditionsTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
        generateLocalEncryptionKeyIfNeeded()
        initialScreenManager.update(onboardingState: .initial)
    }

    private func setupActions() {
        $hasAgreedTermsAndConditions
            .filter { $0 }
            .sink(receiveValue: { [notificationManager] _ in
                notificationManager.requestToken()
            })
            .store(in: cancelBag)

        action
            .filter { $0 == .continueTap }
            .map { _ -> Route in .continueTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .linkTap }
            .map { _ -> Route in .termsAndConditionsTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func generateLocalEncryptionKeyIfNeeded() {
        if Keychain.standard[.localEncryptionKey] == nil {
            let keyCount = 64
            var key = Data(count: keyCount)
            key.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
                let result = SecRandomCopyBytes(kSecRandomDefault, keyCount, pointer.baseAddress!)
                assert(result == 0, "Failed to get random bytes")
            }
            let stringKey = String(data: key, encoding: .macOSRoman)
            Keychain.standard[.localEncryptionKey] = stringKey
        }
    }
}
