//
//  ManagerAssembly.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
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
    }
}
