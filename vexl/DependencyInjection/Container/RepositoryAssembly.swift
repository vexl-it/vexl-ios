//
//  RepositoryAssembly.swift
//  vexl
//
//  Created by Adam Salih on 01.07.2022.
//

import Swinject

final class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UserRepositoryType.self) { _ in
            UserRepository()
        }
        .inObjectScope(.container)

        container.register(ContactsRepositoryType.self) { _ in
            ContactsRepository()
        }
        .inObjectScope(.container)

        container.register(OfferRepositoryType.self) { _ in
            OfferRepository()
        }
        .inObjectScope(.container)

        container.register(InboxRepositoryType.self) { _ in
            InboxRepository()
        }
        .inObjectScope(.container)

        container.register(ChatRepositoryType.self) { _ in
            ChatRepository()
        }
        .inObjectScope(.container)

        container.register(GroupRepositoryType.self) { _ in
            GroupRepository()
        }
        .inObjectScope(.container)
    }
}
