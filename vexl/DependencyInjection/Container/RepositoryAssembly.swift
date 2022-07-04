//
//  RepositoryAssembly.swift
//  vexl
//
//  Created by Diego Espinoza on 3/07/22.
//

import Swinject

class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ChatRepositoryType.self) { _ in
            ChatRepository()
        }
    }
}
