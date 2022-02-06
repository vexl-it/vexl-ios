//
//  Appearance.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit

struct Appearance {
    // MARK: - Colors

    struct Colors {
    }

    // MARK: - Styles

    struct Styles {
        static let oneLineAdjustableLabel = UIViewStyle<UILabel> {
            $0.numberOfLines = 1
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.7
        }
    }

    // MARK: - Global

    static func setGlobalAppearance() {
    }

    // MARK: - Fonts

    static func font(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
