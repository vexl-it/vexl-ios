//
//  RepositoryAssembly.swift
//  vexl
//
//  Created by Adam Salih on 04.07.2022.
//

import Swinject

class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UserRepositoryType.self) { _ in
            UserRepository()
        }
        .inObjectScope(.container)
    }
}
