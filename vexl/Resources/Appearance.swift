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
        static let gray6 = Color(R.color.gray6.name)
        static let green1 = Color(R.color.green1.name)
        static let green4 = Color(R.color.green4.name)
        static let green5 = Color(R.color.green5.name)

        static let yellow100 = Color(R.color.yellow100.name)
        static let yellow20 = Color(R.color.yellow20.name)
        static let yellow60 = Color(R.color.yellow60.name)

        static let whiteOpaque = Color.white.opacity(0.15)

        // MARK: Text

        static let primaryText = Color.black
        static let whiteText = Color.white
    }

    // MARK: - Grid Guide

    struct GridGuide {

        // MARK: Corner Radius

        static let buttonCorner: CGFloat = 12
        static let tabBarCorner: CGFloat = 16

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
        static let baseButtonSize: CGSize = CGSize(width: 40, height: 40)
        static let largeButtonHeight: CGFloat = 64

        // MARK: Avatar

        static let tinyIconSize = CGSize(width: 6, height: 6)
        static let avatarSize = CGSize(width: 190, height: 190)
        static let smallIconSize = CGSize(width: 12, height: 12)
        static let iconSize = CGSize(width: 24, height: 24)
        static let mediumIconSize = CGSize(width: 48, height: 48)
        static let thumbSize = CGSize(width: 38, height: 38)
        static let feedAvatarSize = CGSize(width: 48, height: 48)
        static let feedIconSize = CGSize(width: 32, height: 32)
        static let feedMediumIconSize = CGSize(width: 20, height: 20)
        static let feedSmallIconSize = CGSize(width: 16, height: 16)

        // MARK: Other

        static let feedItemHeight: CGFloat = 52
        static let homeTabBarHeight: CGFloat = 72

        static let scrollContentInset = UIEdgeInsets(top: 0, left: 0, bottom: Self.homeTabBarHeight, right: 0)
    }

    // MARK: - Global

    static func setGlobalAppearance() {
        setDefaultNavBarStyle()
    }

    static func navigationBarDefaultAppearance(withColor color: UIColor = .clear) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance().tap {
            $0.configureWithOpaqueBackground()
            $0.backgroundImage = UIImage()
            $0.shadowColor = .clear
            $0.backgroundColor = color
        }

        return appearance
    }

    static private func setDefaultNavBarStyle() {
        let appearance = navigationBarDefaultAppearance()

        UINavigationBar.appearance().tap {
            $0.prefersLargeTitles = false
            $0.standardAppearance = appearance
            $0.compactAppearance = appearance
            $0.scrollEdgeAppearance = appearance
            $0.isTranslucent = true
            $0.shadowImage = UIImage()
            $0.setBackgroundImage(UIImage(), for: .default)
        }
    }

    // MARK: - Fonts

    enum TextStyle {
        case h1
        case h2
        case h3
        case title
        case titleSmall
        case paragraph
        case paragraphBold
        case paragraphMedium
        case paragraphSmall
        case paragraphSmallBold
        case description
        case descriptionBold
        case micro

        var font: UIFont {
            switch self {
            case .h1:
                return R.font.ppMonumentExtendedBold(size: 40) ?? UIFont.systemFont(ofSize: 40, weight: .bold)
            case .h2:
                return R.font.ppMonumentExtendedBold(size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
            case .h3:
                return R.font.ppMonumentExtendedBold(size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
            case .title:
                return R.font.ttSatoshiRegular(size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .medium)
            case .titleSmall:
                return R.font.ttSatoshiRegular(size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
            case .paragraph:
                return R.font.ttSatoshiRegular(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
            case .paragraphBold:
                return R.font.ttSatoshiBold(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
            case .paragraphMedium:
                return R.font.ttSatoshiMedium(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
            case .paragraphSmall:
                return R.font.ttSatoshiMedium(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
            case .paragraphSmallBold:
                return R.font.ttSatoshiBold(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
            case .description:
                return R.font.ttSatoshiRegular(size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
            case .descriptionBold:
                return R.font.ttSatoshiBold(size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)
            case .micro:
                return R.font.ttSatoshiRegular(size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
            }
        }
    }

    static func font(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
