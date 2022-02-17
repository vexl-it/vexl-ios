//
//  TextStyle.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import UIKit
import SwiftUI

struct TextStyle {
    static let h2 = UIFont.preferredFont(forTextStyle: .title1, weight: .bold)
    static let h3 = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
    static let paragraph = UIFont.preferredFont(forTextStyle: .body, weight: .regular)
}

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
