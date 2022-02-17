//
//  Appearance.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import UIKit
import SwiftUI

struct Appearance {

    // MARK: - Colors

    struct Colors {
        // MARK: General Colors

        static let purple5 = Color(R.color.purple5.name)
        static let gray1 = Color(R.color.gray1.name)
        static let gray2 = Color(R.color.gray2.name)
        static let gray3 = Color(R.color.gray3.name)
        static let green5 = Color(R.color.green5.name)

        // MARK: Text

        static let primaryText = Color.black
    }

    // MARK: - Grid Guide

    struct GridGuide {
        // MARK: Margins

        static let point: CGFloat = 8
        static let padding: CGFloat = 16
        static let mediumPadding: CGFloat = 32
        static let largePadding: CGFloat = 48

        // MARK: Button

        static let largeButtonHeight: CGFloat = 64
    }

    // MARK: - Global

    static func setGlobalAppearance() {
    }

    // MARK: - Fonts

    struct TextStyle {
        static let h2 = UIFont.preferredFont(forTextStyle: .largeTitle, weight: .bold)
        static let h3 = UIFont.preferredFont(forTextStyle: .headline, weight: .semibold)
        static let paragraph = UIFont.preferredFont(forTextStyle: .body, weight: .regular)
        static let paragraphBold = UIFont.preferredFont(forTextStyle: .body, weight: .bold)
    }

    static func font(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
