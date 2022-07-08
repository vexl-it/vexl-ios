//
//  PersistenceManagerAssembly.swift
//  vexl
//
//  Created by Adam Salih on 04.07.2022.
//

import Swinject

class PersistenceManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PersistenceStoreManagerType.self) { _ in
            PersistenceStoreManager()
        }
        .inObjectScope(.container)
    }
}
