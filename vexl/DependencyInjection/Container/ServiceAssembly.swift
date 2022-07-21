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

        container.register(CryptoServiceType.self) { _ in
            CryptoService()
        }
        .inObjectScope(.container)

        container.register(EncryptionServiceType.self) { _ in
            EncryptionService()
        }
        .inObjectScope(.container)

        container.register(UserServiceType.self) { _ in
            UserService()
        }

        container.register(ContactsServiceType.self) { _ in
            ContactsService()
        }

        container.register(OfferServiceType.self) { _ in
            OfferService()
        }

        container.register(ChatServiceType.self) { _ in
            ChatService()
        }

        container.register(LocalStorageServiceType.self) { _ in
            LocalStorageService()
        }
    }
}
