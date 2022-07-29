//
//  Injected.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez Yopla on 24.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

@propertyWrapper
struct Inject<Element> {
    let wrappedValue: Element

    init() {
        self.wrappedValue = DIContainer.shared.getDependency(type: Element.self)
    }
}
