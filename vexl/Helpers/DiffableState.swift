//
//  DiffableState.swift
//  vexl
//
//  Created by Vendula Švastalová on 14.05.2022.
//

import SwiftUI

@propertyWrapper
struct DiffableState<Value>: DynamicProperty where Value: Equatable {
    @State private var value: Value

    init(wrappedValue value: Value) {
        _value = State(wrappedValue: value)
    }

    var wrappedValue: Value {
        get { value }
        nonmutating set {
            if value != newValue {
                value = newValue
            }
        }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
