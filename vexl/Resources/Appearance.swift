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

        static let purple1 = Color(R.color.purple1.name)
        static let purple4 = Color(R.color.purple4.name)
        static let purple5 = Color(R.color.purple5.name)
        static let gray1 = Color(R.color.gray1.name)
        static let gray2 = Color(R.color.gray2.name)
        static let gray3 = Color(R.color.gray3.name)
        static let gray4 = Color(R.color.gray4.name)
        static let gray5 = Color(R.color.gray5.name)
        static let green1 = Color(R.color.green1.name)
        static let green5 = Color(R.color.green5.name)

        // MARK: Text

        static let primaryText = Color.black
    }

    // MARK: - Grid Guide

    struct GridGuide {

        // MARK: Corner Radius

        static let buttonCorner: CGFloat = 12

        // MARK: Margins

        static let smallPadding: CGFloat = 4
        static let point: CGFloat = 8
        static let padding: CGFloat = 16
        static let mediumPadding1: CGFloat = 24
        static let mediumPadding2: CGFloat = 32
        static let largePadding1: CGFloat = 48
        static let largePadding2: CGFloat = 64

        // MARK: Button

        static let baseHeight: CGFloat = 40
        static let largeButtonHeight: CGFloat = 64

        // MARK: Avatar

        static let avatarSize = CGSize(width: 190, height: 190)
    }

    // MARK: - Global

    static func setGlobalAppearance() {
    }

    // MARK: - Fonts

    enum TextStyle {
        case h2
        case h3
        case paragraph
        case paragraphBold
        case description
        case descriptionSemibold

        var font: UIFont {
            switch self {
            case .h2:
                return UIFont.preferredFont(forTextStyle: .largeTitle, weight: .bold)
            case .h3:
                return UIFont.preferredFont(forTextStyle: .title2, weight: .semibold)
            case .paragraph:
                return UIFont.preferredFont(forTextStyle: .body, weight: .regular)
            case .paragraphBold:
                return UIFont.preferredFont(forTextStyle: .body, weight: .bold)
            case .description:
                return UIFont.preferredFont(forTextStyle: .footnote, weight: .regular)
            case .descriptionSemibold:
                return UIFont.preferredFont(forTextStyle: .footnote, weight: .semibold)
            }
        }
    }

    static func font(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
