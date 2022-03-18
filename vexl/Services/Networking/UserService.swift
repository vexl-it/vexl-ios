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
    func validatePhone(phoneNumber: String) -> AnyPublisher<Bool, Error>
    func createUser(username: String, avatar: String) -> AnyPublisher<User, Error>
}

final class UserService: BaseService, UserServiceType {

    var authenticationManager: AuthenticationManager

    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
    }

    func me() -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.me)
    }

    func validatePhone(phoneNumber: String) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { promise in
            after(2) {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }

    func createUser(username: String, avatar: String) -> AnyPublisher<User, Error> {
        AnyPublisher(Future<User, Error> { promise in
            let user = User(id: 1, name: "Diego")
            promise(.success(user))
        })
    }
}
