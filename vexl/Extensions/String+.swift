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

    func calculatedSize(for style: Appearance.TextStyle, horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0, width: CGFloat? = nil, lineLimit: Int = 0) -> CGSize {
        var size: CGSize

        if let width = width {
            let attrString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: style.font])
            let bounds = attrString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            size = CGSize(width: bounds.width, height: bounds.height)
        } else {
            size = self.size(withAttributes: [
                NSAttributedString.Key.font: style.font
            ])
        }

        if lineLimit > 0 {
            let currentHeight = size.height
            size.height = min(style.font.lineHeight * CGFloat(lineLimit), currentHeight)
        }

        size.width += 2 * horizontalPadding
        size.height += 2 * verticalPadding
        return size
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

    func bold(text: String, font: UIFont) {
        guard let underlineRange = string.range(of: text) else {
            return
        }
        let startPosition = string.distance(from: text.startIndex, to: underlineRange.lowerBound)
        let nsrange = NSRange(location: startPosition, length: text.count)
        addAttribute(
            NSAttributedString.Key.font,
            value: font,
            range: nsrange)
    }
}
