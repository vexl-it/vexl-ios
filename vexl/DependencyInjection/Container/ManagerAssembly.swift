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

        container.register(AuthenticationManagerType.self) { resolver in
            resolver.resolve(AuthenticationManager.self)!
        }

        container.register(UserSecurityType.self) { resolver in
            resolver.resolve(AuthenticationManager.self)!
        }

        container.register(TokenHandlerType.self) { resolver in
            resolver.resolve(AuthenticationManager.self)!
        }

        container.register(InitialScreenManager.self) { _ in
            InitialScreenManager()
        }
        .inObjectScope(.container)

        container.register(ContactsManagerType.self) { _ in
            ContactsManager()
        }
        .inObjectScope(.container)

        container.register(CryptoServiceType.self) { _ in
            CryptoService()
        }
        .inObjectScope(.container)

        container.register(CryptocurrencyValueManagerType.self) { _ in
            CryptocurrencyValueManager()
        }
        .inObjectScope(.container)
    }
}
