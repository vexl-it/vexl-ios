//
//  ManagerAssembly.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Swinject

class ManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthenticationManager.self) { _ in
            AuthenticationManager()
        }
        .inObjectScope(.container)

        container.register(TokenHandlerType.self) { resolver in
            resolver.resolve(AuthenticationManager.self)!
        }

        container.register(InitialScreenManager.self) { _ in
            InitialScreenManager()
        }
    }
}
