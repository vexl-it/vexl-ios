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
        container.register(PersistenceStoreManagerType.self) { _ in
            PersistenceStoreManager()
        }
        .inObjectScope(.container)

        container.register(AuthenticationManager.self) { _ in
            AuthenticationManager()
        }
        .inObjectScope(.container)

        container.register(AuthenticationManagerType.self) { resolver in
            resolver.resolve(AuthenticationManager.self)!
        }

        container.register(SyncQueueManagerType.self) { _ in
            SyncQueueManager()
        }
        .inObjectScope(.container)

        container.register(NetworkManagerType.self) { _ in
            NetworkManager()
        }
        .inObjectScope(.container)

        container.register(InitialScreenManager.self) { _ in
            InitialScreenManager()
        }
        .inObjectScope(.container)

        container.register(ContactsManagerType.self) { _ in
            ContactsManager()
        }
        .inObjectScope(.container)

        container.register(CryptocurrencyValueManagerType.self) { _ in
            CryptocurrencyValueManager(option: .oneDayAgo)
        }
        .inObjectScope(.container)

        container.register(SyncInboxManagerType.self) { _ in
            SyncInboxManager()
        }
        .inObjectScope(.container)

        container.register(InboxManagerType.self) { _ in
            InboxManager()
        }
        .inObjectScope(.container)

        container.register(FacebookManagerType.self) { _ in
            FacebookManager()
        }
        .inObjectScope(.container)

        container.register(OfferManagerType.self) { _ in
            OfferManager()
        }
        .inObjectScope(.container)

        container.register(ChatManagerType.self) { _ in
            ChatManager()
        }
        .inObjectScope(.container)

        container.register(NotificationManagerType.self) { _ in
            NotificationManager()
        }
        .inObjectScope(.container)

        container.register(GroupManagerType.self) { _ in
            GroupManager()
        }
        .inObjectScope(.container)

        container.register(DeeplinkManagerType.self) { _ in
            DeeplinkManager()
        }
        .inObjectScope(.container)
    }
}
