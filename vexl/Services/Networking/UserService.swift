//
//  UserService.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Combine

struct ChallengeValidation: Codable {
    var hash: String
    var signature: String
    var challengeVerified: Bool
}

protocol UserServiceType {
    func me() -> AnyPublisher<User, Error>
    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneVerification, Error>
    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidation, Error>
    func validateChallenge(key: String, signature: String) -> AnyPublisher<ChallengeValidation, Error>
    func validateUsername(username: String) -> AnyPublisher<UserAvailable, Error>
    func createUser(username: String, avatar: String?) -> AnyPublisher<User, Error>
    // temporal
    func generateKeys() -> AnyPublisher<UserKeys, Error>
    func generateSignature(challenge: String, privateKey: String) -> AnyPublisher<UserSignature, Error>
}

final class UserService: BaseService, UserServiceType {

    var authenticationManager: AuthenticationManager

    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
    }

    func me() -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.me)
    }

    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneVerification, Error> {
        request(type: PhoneVerification.self, endpoint: UserRouter.confirmPhone(phoneNumber: phoneNumber))
            .eraseToAnyPublisher()
    }

    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidation, Error> {
        request(type: CodeValidation.self, endpoint: UserRouter.validateCode(id: id, code: code, key: key))
            .eraseToAnyPublisher()
    }

    func validateChallenge(key: String, signature: String) -> AnyPublisher<ChallengeValidation, Error> {
        request(type: ChallengeValidation.self, endpoint: UserRouter.validateChallenge(signature: signature, key: key))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setHash(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func validateUsername(username: String) -> AnyPublisher<UserAvailable, Error> {
        request(type: UserAvailable.self, endpoint: UserRouter.validateUsername(username: username))
            .eraseToAnyPublisher()
    }

    func createUser(username: String, avatar: String?) -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.createUser(username: username, avatar: avatar))
            .eraseToAnyPublisher()
    }

    // TODO: - Temporal delete once C library is implemented

    func generateKeys() -> AnyPublisher<UserKeys, Error> {
        request(type: UserKeys.self, endpoint: UserRouter.temporalGenerateKeys)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setUserKeys(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func generateSignature(challenge: String, privateKey: String) -> AnyPublisher<UserSignature, Error> {
        request(type: UserSignature.self, endpoint: UserRouter.temporalSignature(challenge: challenge, privateKey: privateKey))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setUserSignature(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }
}
