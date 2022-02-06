//
//  ViewModelType.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

protocol ViewModelType {
    associatedtype Bindings

    init(bindings: Bindings)
}

struct ViewModelWrapper<VM: ViewModelType> {
    func bind(_ bindings: VM.Bindings) -> VM {
        VM(bindings: bindings)
    }
}
