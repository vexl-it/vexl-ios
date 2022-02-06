//
//  AuthenticationManager.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import RxSwift
import RxCocoa
import KeychainAccess

typealias BearerToken = String

protocol TokenHandlerType {
    var accessToken: BearerToken? { get }
    var refreshToken: BearerToken? { get }
}

final class AuthenticationManager: TokenHandlerType {
    enum AuthenticationState {
        case signedIn
        case signedOut
    }

    var accessToken: BearerToken? { currentAccessToken.value }
    var refreshToken: BearerToken? { currentRefreshToken.value }

    // MARK: - Properties

    let authenticationState = BehaviorRelay<AuthenticationState>(value: .signedOut)

    private let currentAccessToken = BehaviorRelay<String?>(value: nil)
    private let currentRefreshToken = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()

    // MARK: - Initialization

    init() {
        currentAccessToken.accept(Keychain.standard[.accessToken])
        currentRefreshToken.accept(Keychain.standard[.refreshToken])

        setupSubscription()
    }

    private func setupSubscription() {
        currentAccessToken
            .subscribe(onNext: { accessToken in
                Keychain.standard[.accessToken] = accessToken
            })
            .disposed(by: disposeBag)

        currentRefreshToken
            .subscribe(onNext: { refreshToken in
                Keychain.standard[.refreshToken] = refreshToken
            })
            .disposed(by: disposeBag)

        currentAccessToken
            .map { $0 ?? "" }
            .map { $0.isEmpty ? .signedOut : .signedIn }
            .bind(to: authenticationState)
            .disposed(by: disposeBag)
    }
}

// MARK: - Methods

extension AuthenticationManager {
    func setAccessToken(token: String) {
        currentAccessToken.accept(token)
    }

    func setRefreshToken(token: String) {
        currentRefreshToken.accept(token)
    }

    func clearUser() {
        currentAccessToken.accept(nil)
        currentRefreshToken.accept(nil)
        UserDefaultsConfig.removeAll()
    }
}
