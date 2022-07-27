//
//  BaseCoordinator.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 14.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import Foundation
import Combine
import SwiftUI

public protocol PopHandler {
    var dismissPublisher: ActionSubject<Void> { get }
}

public protocol DismissHandler {
    var dismissPublisher: ActionSubject<Void> { get }
}

/// Base abstract coordinator generic over the return type of the `start` method.
open class BaseCoordinator<ResultType>: NSObject, Coordinator {

    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationResult`.
    public typealias CoordinationResult = ResultType

    /// Utility `DisposeBag` used by the subclasses.
    public let cancelBag = CancelBag()
    public var cancellable: AnyCancellable?

    /// Unique identifier.
    public let identifier = UUID()

    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
    /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
    private var childCoordinators = [UUID: Any]()

    /// Stores coordinator to the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Child coordinator to store.
    private func store<T: Coordinator>(coordinator: T) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    /// Release coordinator from the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Coordinator to release.
    private func free<T: Coordinator>(coordinator: T) {
        childCoordinators[coordinator.identifier] = nil
    }

    /// 1. Stores coordinator in a dictionary of child coordinators.
    /// 2. Calls method `start()` on that coordinator.
    /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    ///
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    public func coordinate<T: Coordinator, U>(to coordinator: T) -> CoordinatingResult<U> where U == T.CoordinationResult {
        store(coordinator: coordinator)
        return coordinator.start()
            .handleEvents(receiveOutput: { [weak self] _ in self?.free(coordinator: coordinator) })
            .eraseToAnyPublisher()
    }

    public func dismissObservable(with popHandler: PopHandler, dismissHandler: DismissHandler) -> AnyPublisher<Void, Never> {
        let popped = popHandler.dismissPublisher
        let dismissed = dismissHandler.dismissPublisher
        return Publishers.Merge(popped, dismissed).eraseToAnyPublisher()
    }

    /// Starts job of the coordinator.
    ///
    /// - Returns: Result of coordinator job.
    open func start() -> CoordinatingResult<ResultType> {
        fatalError("Start method should be implemented.")
    }
}
