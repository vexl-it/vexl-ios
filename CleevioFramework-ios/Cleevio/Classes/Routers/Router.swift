//
//  Router.swift
//
//  Created by Thành Đỗ Long on 17.03.2021.
//

import UIKit
import Combine

#if !COCOAPODS
import CleevioCore
#endif

public enum RouterResult<T> {
    case dismiss
    case dismissedByRouter
    case finished(T)
    
    public var value: T? {
        guard case let .finished(value) = self else {
            return nil
        }
        return value
    }
}

extension RouterResult {
    func mapFinished<Result>(_ transform: (T) -> Result) -> RouterResult<Result> {
        switch self {
        case .finished(let value):
            return .finished(transform(value))
        case .dismiss:
            return .dismiss
        case .dismissedByRouter:
            return .dismissedByRouter
        }
    }
}

extension RouterResult: Equatable {
    public static func == (lhs: RouterResult<T>, rhs: RouterResult<T>) -> Bool {
        switch (lhs, rhs) {
        case (.dismiss, dismiss):
            return true
        case (.dismissedByRouter, .dismissedByRouter):
            return true
        case (.finished, .finished):
            return true
        default:
            return false
        }
    }
}

public protocol Router: AnyObject, DismissHandler {
    func present(_ viewController: UIViewController, animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
    func dismiss<T>(animated: Bool, returning result: RouterResult<T>) -> AnyPublisher<RouterResult<T>, Never>
}

public extension Router {
    func dismiss(animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
    
    func dismiss<T>(animated: Bool, returning result: RouterResult<T>) -> AnyPublisher<RouterResult<T>, Never> {
        Future { [weak self] promise in
            self?.dismiss(animated: animated) {
                promise(.success(result))
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Failure == Never {
    func dismissedByRouter<T>(type: T.Type) -> AnyPublisher<RouterResult<T>, Never> {
        self
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<T>.dismissedByRouter }
            .eraseToAnyPublisher()
    }
}
