//
//  String+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import UIKit

extension String {

    var ptr: UnsafeMutablePointer<CChar>? {
        let nsSelf = NSString(string: self)
        return UnsafeMutablePointer<CChar>(mutating: nsSelf.utf8String)
    }

    var capitalizeFirstLetter: String {
        prefix(1).uppercased() + lowercased().dropFirst()
    }

    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension String: Identifiable {
    public var id: Int { hashValue }
}

extension NSMutableAttributedString {
    func setAsLink(textToFind: String,
                   linkURL: String,
                   linkColor: UIColor,
                   linkFont: UIFont?,
                   underline: Bool = false) {
        let foundRange = self.mutableString.range(of: textToFind)

        if foundRange.location != NSNotFound {

            self.addAttribute(.link, value: linkURL, range: foundRange)
            self.addAttributes([.foregroundColor: linkColor], range: foundRange)

            if underline {
                self.addAttributes([.foregroundColor: linkColor], range: foundRange)
            }

            if let linkFont = linkFont {
                self.addAttributes([.font: linkFont], range: foundRange)
            }
        }
    }

    func underline(term: String) {
        guard let underlineRange = string.range(of: term) else {
            return
        }
        let startPosition = string.distance(from: term.startIndex, to: underlineRange.lowerBound)
        let nsrange = NSRange(location: startPosition, length: term.count)
        addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: nsrange)
    }
}
