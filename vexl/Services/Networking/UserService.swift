//
//  UserService.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import RxSwift
import RxCocoa

protocol UserServiceType {
    func me() -> Single<User>
}

final class UserService: BaseService, UserServiceType {
    func me() -> Single<User> {
        request(type: User.self, endpoint: UserRouter.me)
    }
}
