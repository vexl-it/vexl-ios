//
//  ManagerAssembly.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez Yopla on 24.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Swinject

class ManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthenticationManager.self) { _ in
            AuthenticationManager()
        }
        .inObjectScope(.container)

        container.register(InitialScreenManager.self) { _ in
            InitialScreenManager()
        }
        .inObjectScope(.container)
        
        container.register(CounterManagerType.self) { _, counter in
            CounterManager(counter: counter)
        }
        .inObjectScope(.container)

        container.register(CounterManagerType.self) { _ in 
            CounterManager()
        }
        .inObjectScope(.container)
    }
}
