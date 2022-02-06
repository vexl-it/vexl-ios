//
//  String+.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation

extension String {
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
