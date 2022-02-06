//
//  ReusableView.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
