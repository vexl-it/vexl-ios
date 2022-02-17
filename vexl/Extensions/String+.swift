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
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func configureAttributedText() -> NSMutableAttributedString {
        var attributedString = NSMutableAttributedString(string: self)

        AttributedMacro.allCases.forEach { macro in
            attributedString = replaceMacroWithFormatting(for: attributedString,
                                                          replace: macro)
        }

        return attributedString
    }

    func replaceMacroWithFormatting(for attributedString: NSMutableAttributedString,
                                    replace attributedMacro: AttributedMacro) -> NSMutableAttributedString {
        do {
            let range = NSRange(location: 0, length: attributedString.string.count)
            // swiftlint:disable line_length
            let regexFormat = try NSRegularExpression(pattern: "(\\{\\{\(attributedMacro.rawValue)\\}\\})(.*?)(\\{\\{\\/\(attributedMacro.rawValue)\\}\\})")
            let matchesFormat = regexFormat
                .matches(in: attributedString.string,
                         range: range)
                .reversed()

            matchesFormat.forEach { match in
                let substring = (attributedString.string as NSString).substring(with: match.range(at: 2))
                let newAttributedString = NSAttributedString(string: substring, attributes: attributedMacro.attributes)
                attributedString.replaceCharacters(in: match.range, with: newAttributedString)
            }
        } catch let error {
            log.error(error)
        }

        return attributedString
    }
}

extension NSMutableAttributedString {
    func setAsLink(textToFind: String,
                   linkURL: String,
                   linkColor: UIColor,
                   underline: Bool = false,
                   bold: Bool = false) {
        let foundRange = self.mutableString.range(of: textToFind)

        if foundRange.location != NSNotFound {

            self.addAttribute(.link, value: linkURL, range: foundRange)
            if underline {
                self.addAttributes(
                    [
                        .foregroundColor: linkColor
                    ], range: foundRange)
            }

            if bold {
                self.addAttributes(
                    [
                        .font: Appearance.TextStyle.paragraphBold,
                        .foregroundColor: linkColor
                    ], range: foundRange)
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

public enum AttributedMacro: String, CaseIterable {
    case bold = "b"
    case underline = "u"

    var attributes: [NSAttributedString.Key: Any] {
        switch self {
        case .bold:
            return [
                .font: Appearance.TextStyle.paragraphBold
            ]

        case .underline:
            return [
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        }
    }
}
