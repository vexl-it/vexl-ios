//
//  DidSet.swift
//  vexl
//
//  Created by Diego Espinoza on 12/05/22.
//

import Combine

/// Property wrapper similar to @Published but instead of publishing the event in `willSet` it will do it in `didSet`
/// It contains a `CurrentValueSubject<Value>`

@propertyWrapper
class DidSet<Value> {
    private var value: Value
    private let subject: CurrentValueSubject<Value, Never>

    init(wrappedValue value: Value) {
        self.value = value
        subject = CurrentValueSubject(value)
        wrappedValue = value
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            subject.send(value)
        }
    }

    public var projectedValue: CurrentValueSubject<Value, Never> {
        get { subject }
        set { _ = newValue }
    }
}
