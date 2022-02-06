//
//  Coordinator.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import RxSwift

enum PushCoordinationResult<T> {
    case popped
    case dismiss
    case finished(T)
}

enum ModalCoordinationResult<T> {
    case dismissed
    case dismiss
    case finished(T)
}

protocol Coordinator {
    associatedtype CoordinationResult

    var identifier: UUID { get }

    func start() -> Observable<CoordinationResult>
}
