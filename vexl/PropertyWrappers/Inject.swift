//
//  Inject.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

@propertyWrapper
struct Inject<Element> {
    let wrappedValue: Element

    init() {
        self.wrappedValue = DIContainer.shared.getDependency(type: Element.self)
    }
}
