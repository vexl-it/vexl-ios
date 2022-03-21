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
}

final class UserService: BaseService, UserServiceType {

    static var temporal: Date {
        var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date())
        components.second = (components.second ?? 0) + 15
        return Calendar.current.date(from: components) ?? Date()
    }

    var authenticationManager: AuthenticationManager

    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
    }

    func me() -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.me)
    }

    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneConfirmationResponse, Error> {
        AnyPublisher(
            Future { promise in
                after(2) {
                    let resp = PhoneConfirmationResponse(verificationId: 1, expirationAt: "")
                    promise(.success(resp))
                }
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setPhoneVerification(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
        )
//        request(type: PhoneConfirmationResponse.self, endpoint: UserRouter.confirmPhone(phoneNumber: phoneNumber))
//            .withUnretained(self)
//            .handleEvents(receiveOutput: { owner, response in
//                owner.authenticationManager.setPhoneVerification(response)
//            })
//            .map { $0.1 }
//            .eraseToAnyPublisher()
    }

    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidationResponse, Error> {
        AnyPublisher(
            Future { promise in
                let response = CodeValidationResponse(challenge: "qwerty", phoneVerified: true)
                promise(.success(response))
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.authenticationManager.setCodeConfirmation(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
        )
//        request(type: CodeValidationResponse.self, endpoint: UserRouter.validateCode(id: id, code: code, key: key))
//            .withUnretained(self)
//            .handleEvents(receiveOutput: { owner, response in
//                owner.authenticationManager.setCodeConfirmation(response)
//            })
//            .map { $0.1 }
//            .eraseToAnyPublisher()
    }

    func createUser(username: String, avatar: String) -> AnyPublisher<User, Error> {
        AnyPublisher(Future<User, Error> { promise in
            let user = User(id: 1, name: "Diego")
            promise(.success(user))
        })
    }
}
