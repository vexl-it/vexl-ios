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

        container.register(ApiServiceType.self) { _ in
            ApiService()
        }

        container.register(UserServiceType.self) { _ in
            UserService()
        }

        container.register(ContactsServiceType.self) { _ in
            ContactsService()
        }

        container.register(OfferServiceType.self) { _ in
            OfferService()
        }
    }
}
