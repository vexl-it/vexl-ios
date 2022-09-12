//
//  Clampable.swift
//  pilulka
//
//  Created by Adam Salih on 08.11.2021.
//

import UIKit

protocol Clampable {
    func clamped(from: Self, to: Self) -> Self
}

extension Clampable where Self: Comparable {
    func clamped(from: Self, to: Self) -> Self {
        switch self {
        case let value where value < from:
            return from
        case let value where value > to:
            return to
        default:
            return self
        }
    }
}

extension CGFloat: Clampable {}
extension Int: Clampable {}
