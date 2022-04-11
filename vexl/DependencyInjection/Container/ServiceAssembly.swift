//
//  ServiceAssembly.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Swinject

class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ApiInterceptor.self) { _ in
            ApiInterceptor()
        }

        container.register(ApiServiceType.self) { container in
            ApiService(
                authenticationManager: container.resolve(TokenHandlerType.self)!
            )
        }

        container.register(UserServiceType.self) { container in
            UserService(authenticationManager: container.resolve(AuthenticationManager.self)!)
        }

        container.register(ContactsServiceType.self) { container in
            ContactsService(contactsManager: container.resolve(ContactsManagerType.self)!)
        }
    }
}
