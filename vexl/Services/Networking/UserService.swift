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
    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneVerification, Error>
    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidation, Error>
    func validateChallenge(key: String, signature: String) -> AnyPublisher<ChallengeValidation, Error>
    func validateUsername(username: String) -> AnyPublisher<UserAvailable, Error>
    func createUser(username: String, avatar: String?) -> AnyPublisher<User, Error>
    func updateUser(username: String, avatar: String?) -> AnyPublisher<EditUser, Error>
    func deleteUser() -> AnyPublisher<Void, Error>
    func facebookSignature(id: String) -> AnyPublisher<ChallengeValidation, Error>
    func getBitcoinData() -> AnyPublisher<CoinData, Error>
    func getBitcoinChartData(currency: Currency, option: TimelineOption) -> AnyPublisher<CoinChartData, Error>
}

final class UserService: BaseService, UserServiceType {

    @Inject var userSecurity: UserSecurityType
    @Inject var authenticationManager: AuthenticationManagerType

    func me() -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.me)
    }

    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneVerification, Error> {
        request(type: PhoneVerification.self, endpoint: UserRouter.confirmPhone(phoneNumber: phoneNumber))
            .mapError { _ in UserError.invalidPhoneNumber }
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
                owner.userSecurity.setHash(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func validateUsername(username: String) -> AnyPublisher<UserAvailable, Error> {
        request(type: UserAvailable.self, endpoint: UserRouter.validateUsername(username: username))
            .eraseToAnyPublisher()
    }

    func createUser(username: String, avatar: String?) -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.createUser(username: username,
                                                                 avatar: avatar,
                                                                 imageExtension: Constants.jpegFormat))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                let avatarData = avatar?.dataFromBase64
                owner.authenticationManager.setUser(response, withAvatar: avatarData)
            })
            .map(\.1)
            .eraseToAnyPublisher()
    }

    func updateUser(username: String, avatar: String?) -> AnyPublisher<EditUser, Error> {
        request(type: EditUser.self, endpoint: UserRouter.updateUser(username: username,
                                                                     avatar: avatar,
                                                                     imageExtension: Constants.jpegFormat))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.authenticationManager.updateUser(username: username, withAvatar: avatar?.dataFromBase64)
            })
            .map(\.1)
            .eraseToAnyPublisher()
    }

    func deleteUser() -> AnyPublisher<Void, Error> {
        request(endpoint: UserRouter.deleteUser)
    }

    func facebookSignature(id: String) -> AnyPublisher<ChallengeValidation, Error> {
        request(type: ChallengeValidation.self, endpoint: UserRouter.facebookSignature(id: id))
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                owner.userSecurity.setFacebookSignature(response)
            })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }

    func getBitcoinData() -> AnyPublisher<CoinData, Error> {
        request(type: CoinData.self, endpoint: UserRouter.bitcoin)
            .eraseToAnyPublisher()
    }

    func getBitcoinChartData(currency: Currency, option: TimelineOption) -> AnyPublisher<CoinChartData, Error> {
        request(type: CoinChartData.self, endpoint: UserRouter.bitcoinChart(currency: currency, option: option))
            .eraseToAnyPublisher()
    }
}
