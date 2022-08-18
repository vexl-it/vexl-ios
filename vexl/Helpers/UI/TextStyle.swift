//
//  TextStyle.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import UIKit
import SwiftUI

extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}

extension UIFont {
    var asFont: Font { Font(uiFont: self) }
    
    static func preferredFont(forTextStyle style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}

struct TextStyle: ViewModifier {
    let textStyle: Appearance.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(textStyle.font.asFont)
    }
}

extension View {
    func textStyle(_ textStyle: Appearance.TextStyle) -> some View {
        modifier(TextStyle(textStyle: textStyle))
    }
}

extension Text {
    func textStyle(_ textStyle: Appearance.TextStyle) -> Text {
        self.font(textStyle.font.asFont)
    }
}

extension UILabel {
    func textStyle(_ textStyle: Appearance.TextStyle) {
        font = textStyle.font
    }
}
