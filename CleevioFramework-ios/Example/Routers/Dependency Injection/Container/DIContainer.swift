//
//  DIContainer.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez Yopla on 24.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Swinject

class DIContainer {

    static let shared = DIContainer()

    let assembler = Assembler([
        ManagerAssembly(),
        ServiceAssembly(),
    ])

    func getDependency<Dependency>(type: Dependency.Type) -> Dependency {
        guard let dependency = DIContainer.shared.assembler.resolver.resolve(Dependency.self) else {
            fatalError("Dependency \(type) wasn't setup")
        }
        return dependency
    }

    func getDependency<Dependency>(type: Dependency.Type, args: Any...) -> Dependency {
        var dependency: Dependency?

        switch args.count {
        case 1:
            dependency = DIContainer.shared.assembler.resolver.resolve(Dependency.self, argument: args[0])
        case 2:
            dependency = DIContainer.shared.assembler.resolver.resolve(Dependency.self, arguments: args[0], args[1])
        default:
            fatalError("Use the correct method from resolver to instantiate the Dependency with N arguments.")
        }

        guard dependency != nil else { fatalError("Dependency \(type) wasn't setup") }
        return dependency!
    }
}
