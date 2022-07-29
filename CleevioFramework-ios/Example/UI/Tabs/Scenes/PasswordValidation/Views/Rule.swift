//
//  Rule.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 11/14/20.
//

import Foundation

protocol RuleType {
    var title: String { get }
}

struct Rule: Identifiable, Hashable {
    internal var id: PasswordRule { type }
    let type: PasswordRule
    var title: String { type.title }
    var isCompleted: Bool
}
