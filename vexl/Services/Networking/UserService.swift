//
//  UserService.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Combine

protocol UserServiceType {
    func me() -> AnyPublisher<User, Error>
    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneConfirmationResponse, Error>
    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidationResponse, Error>
    func createUser(username: String, avatar: String) -> AnyPublisher<User, Error>
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

    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneConfirmationResponse, Error> {
        request(type: PhoneConfirmationResponse.self, endpoint: UserRouter.confirmPhone(phoneNumber: phoneNumber))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setPhoneVerification(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidationResponse, Error> {
        request(type: CodeValidationResponse.self, endpoint: UserRouter.validateCode(id: id, code: code, key: key))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setCodeConfirmation(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func createUser(username: String, avatar: String) -> AnyPublisher<User, Error> {
        AnyPublisher(Future<User, Error> { promise in
            after(2) {
                let user = User(id: 1, name: "Diego")
                promise(.success(user))
            }
        })
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
