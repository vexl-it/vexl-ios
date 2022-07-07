//
//  RepositoryAssembly.swift
//  vexl
//
//  Created by Adam Salih on 01.07.2022.
//

import Swinject

class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UserRepositoryType.self) { _ in
            UserRepository()
        }
        .inObjectScope(.container)

        container.register(ChatRepositoryType.self) { _ in
            ChatRepository()
        }
    }
}
