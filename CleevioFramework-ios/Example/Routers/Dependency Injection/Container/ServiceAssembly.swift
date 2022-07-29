//
//  ServiceAssembly.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez Yopla on 24.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Swinject

class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FirstDummyServiceType.self) { _ in
            FirstDummyService()
        }
        
        container.register(SecondDummyServiceType.self) { _ in
            SecondDummyService()
        }
    }
}
