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
    func requestVerificationCode(phoneNumber: String) -> AnyPublisher<PhoneVerification, Error>
    func confirmValidationCode(id: Int, code: String, key: String) -> AnyPublisher<CodeValidation, Error>
    func validateChallenge(key: String, signature: String) -> AnyPublisher<ChallengeValidation, Error>
    func facebookSignature(id: String) -> AnyPublisher<ChallengeValidation, Error>
    func getBitcoinData() -> AnyPublisher<CoinData, Error>
    func getBitcoinChartData(currency: Currency, option: TimelineOption) -> AnyPublisher<CoinChartData, Error>
}

final class UserService: BaseService, UserServiceType {

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
            .eraseToAnyPublisher()
    }

    func facebookSignature(id: String) -> AnyPublisher<ChallengeValidation, Error> {
        request(type: ChallengeValidation.self, endpoint: UserRouter.facebookSignature(id: id))
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
