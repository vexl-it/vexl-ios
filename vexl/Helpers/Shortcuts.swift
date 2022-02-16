//
//  Shortcuts.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

public extension NSObjectProtocol {
    @discardableResult
    func tap(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

@discardableResult
public func tap<T>(_ value: T, block: (T) -> Void) -> T {
    let copy = value
    block(copy)
    return copy
}

public func after(_ seconds: TimeInterval, block: @escaping () -> Void) {
    let nanoseconds = Int64(seconds * TimeInterval(NSEC_PER_SEC))
    let time = DispatchTime.now() + Double(nanoseconds) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: block)
}

/**
 Will execute block on next cycle of CFRunLoop, so it will run in very near future.
 */
public func performNextCycle(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
