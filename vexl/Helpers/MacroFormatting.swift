//
//  MacroFormatting.swift
//  vexl
//
//  Created by Thành Đỗ Long on 29.08.2022.
//

import Foundation
import UIKit

extension String {
    func configureAttributedText(atributedMacros: [AttributedMacro] = DefaultAttributedMacro.atributedMacros,
                                 textColor: UIColor? = R.color.gray3(),
                                 textStyle: Appearance.TextStyle? = .paragraph) -> NSMutableAttributedString {
        var attributedString = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attributedString.string.count)
        
        if let textColor = textColor {
            attributedString.addAttribute(.foregroundColor,
                                          value: textColor,
                                          range: range)
        }
        
        if let textStyle = textStyle {
            attributedString.addAttribute(.font,
                                          value: textStyle.font,
                                          range: range)
        }
        
        atributedMacros.forEach { macro in
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
            let regexFormat = try NSRegularExpression(pattern: "(\\{\\{\(attributedMacro.macro)\\}\\})(.*?)(\\{\\{\\/\(attributedMacro.macro)\\}\\})")
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

struct AttributedMacro {
    var macro: String
    var attributes: [NSAttributedString.Key: Any]
}

public enum DefaultAttributedMacro: String, CaseIterable {
    case bold = "b"
    case underline = "u"
    
    static var atributedMacros: [AttributedMacro] {
        DefaultAttributedMacro.allCases.map {
            AttributedMacro(macro: $0.rawValue,
                            attributes: $0.attributes) }
    }
    
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

public enum FAQAttributedMacro: String, CaseIterable {
    case bold = "b"
    case header = "header"
    case underline = "u"
    
    static var atributedMacros: [AttributedMacro] {
        FAQAttributedMacro.allCases.map {
            AttributedMacro(macro: $0.rawValue,
                            attributes: $0.attributes) }
    }
    
    var attributes: [NSAttributedString.Key: Any] {
        switch self {
        case .bold: return [ .font: Appearance.TextStyle.paragraphBold.font,
                             .foregroundColor: UIColor(Appearance.Colors.whiteText)]
        case .header: return [ .font: Appearance.TextStyle.paragraphBold.font,
                               .foregroundColor: UIColor(Appearance.Colors.whiteText)]
        case .underline: return [ .font: Appearance.TextStyle.paragraphBold.font,
                                  .foregroundColor: UIColor(Appearance.Colors.gray3),
                                  .underlineStyle: NSUnderlineStyle.single.rawValue]
        }
    }
}
