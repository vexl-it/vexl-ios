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

        static let black1 = Color(R.color.black1.name)
        static let purple1 = Color(R.color.purple1.name)
        static let purple4 = Color(R.color.purple4.name)
        static let purple5 = Color(R.color.purple5.name)
        static let gray1 = Color(R.color.gray1.name)
        static let gray2 = Color(R.color.gray2.name)
        static let gray3 = Color(R.color.gray3.name)
        static let gray4 = Color(R.color.gray4.name)
        static let gray5 = Color(R.color.gray5.name)
        static let green1 = Color(R.color.green1.name)
        static let green4 = Color(R.color.green4.name)
        static let green5 = Color(R.color.green5.name)

        // MARK: Text

        static let primaryText = Color.black
        static let whiteText = Color.white
    }

    // MARK: - Grid Guide

    struct GridGuide {

        // MARK: Corner Radius

        static let buttonCorner: CGFloat = 12

        // MARK: Margins

        static let tinyPadding: CGFloat = 4
        static let point: CGFloat = 8
        static let smallPadding: CGFloat = 12
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
        static let smallIconSize = CGSize(width: 12, height: 12)
        static let iconSize = CGSize(width: 24, height: 24)
        static let mediumIconSize = CGSize(width: 48, height: 48)
        static let thumbSize = CGSize(width: 38, height: 38)

        // MARK: Other
        static let feedItemHeight: CGFloat = 52
    }

    // MARK: - Global

    static func setGlobalAppearance() {
    }

    // MARK: - Fonts

    enum TextStyle {
        case h1
        case h2
        case h3
        case paragraph
        case paragraphBold
        case paragraphMedium
        case description
        case descriptionSemibold
        case micro

        var font: UIFont {
            switch self {
            case .h1:
                return UIFont.systemFont(ofSize: 54, weight: .bold)
            case .h2:
                return UIFont.preferredFont(forTextStyle: .largeTitle, weight: .bold)
            case .h3:
                return UIFont.preferredFont(forTextStyle: .title2, weight: .semibold)
            case .paragraph:
                return UIFont.preferredFont(forTextStyle: .body, weight: .regular)
            case .paragraphBold:
                return UIFont.preferredFont(forTextStyle: .body, weight: .bold)
            case .paragraphMedium:
                return UIFont.preferredFont(forTextStyle: .body, weight: .medium)
            case .description:
                return UIFont.preferredFont(forTextStyle: .footnote, weight: .regular)
            case .descriptionSemibold:
                return UIFont.preferredFont(forTextStyle: .footnote, weight: .semibold)
            case .micro:
                return UIFont.preferredFont(forTextStyle: .caption1, weight: .regular)
            }
        }
    }

    static func font(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
