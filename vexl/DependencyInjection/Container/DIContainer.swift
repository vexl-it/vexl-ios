//
//  DIContainer.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Swinject

class DIContainer {
    static let shared = DIContainer()

    let assembler = Assembler([
        ManagerAssembly(),
        ServiceAssembly()
    ])

    private init() { }

    func getDependency<Dependency>(type: Dependency.Type) -> Dependency {
        let syncResolver = (DIContainer.shared.assembler.resolver as? Container)?.synchronize()
        guard let dependency = syncResolver?.resolve(Dependency.self) else {
            fatalError("Dependency \(type) wasn't setup")
        }
        return dependency
    }

    func getDependency<Dependency>(type: Dependency.Type, args: Any...) -> Dependency {
        var dependency: Dependency?
        let syncResolver = (DIContainer.shared.assembler.resolver as? Container)?.synchronize()

        switch args.count {
        case 1:
            dependency = syncResolver?.resolve(Dependency.self, argument: args[0])
        case 2:
            dependency = syncResolver?.resolve(Dependency.self, arguments: args[0], args[1])
        default:
            fatalError("Use the correct method from resolver to instantiate the Dependency with N arguments.")
        }

        guard dependency != nil else { fatalError("Dependency \(type) wasn't setup") }
        return dependency!
    }
}
