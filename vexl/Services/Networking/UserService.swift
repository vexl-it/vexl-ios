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
}

final class UserService: BaseService, UserServiceType {
    func me() -> AnyPublisher<User, Error> {
        request(type: User.self, endpoint: UserRouter.me)
    }
}
