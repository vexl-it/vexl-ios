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

    static let dimmingViewOpacity: CGFloat = 0.8

    // MARK: - Colors

    struct Colors {
        // MARK: General Colors

        static let black1 = Color(R.color.black1.name)
        static let purple1 = Color(R.color.purple1.name)
        static let purple3 = Color(R.color.purple3.name)
        static let purple4 = Color(R.color.purple4.name)
        static let purple5 = Color(R.color.purple5.name)
        static let gray1 = Color(R.color.gray1.name)
        static let gray2 = Color(R.color.gray2.name)
        static let gray3 = Color(R.color.gray3.name)
        static let gray4 = Color(R.color.gray4.name)
        static let gray5 = Color(R.color.gray5.name)
        static let gray6 = Color(R.color.gray6.name)

        static let green20 = Color(R.color.green20.name)
        static let green30 = Color(R.color.green30.name)
        static let green40 = Color(R.color.green40.name)
        static let green50 = Color(R.color.green50.name)
        static let green60 = Color(R.color.green60.name)
        static let green100 = Color(R.color.green100.name)

        static let yellow20 = Color(R.color.yellow20.name)
        static let yellow30 = Color(R.color.yellow30.name)
        static let yellow40 = Color(R.color.yellow40.name)
        static let yellow50 = Color(R.color.yellow50.name)
        static let yellow60 = Color(R.color.yellow60.name)
        static let yellow100 = Color(R.color.yellow100.name)

        static let pink20 = Color(R.color.pink20.name)
        static let pink30 = Color(R.color.pink30.name)
        static let pink40 = Color(R.color.pink40.name)
        static let pink50 = Color(R.color.pink50.name)
        static let pink60 = Color(R.color.pink60.name)
        static let pink100 = Color(R.color.pink100.name)

        static let red100 = Color(R.color.red100.name)
        static let red20 = Color(R.color.red20.name)

        static let whiteOpaque = Color.white.opacity(0.15)

        // MARK: Text

        static let primaryText = Color.black
        static let whiteText = Color.white
    }

    // MARK: - Grid Guide

    struct GridGuide {

        // MARK: Corner Radius

        static let groupLabelCorner: CGFloat = 8
        static let containerCorner: CGFloat = 10
        static let buttonCorner: CGFloat = 12
        static let tabBarCorner: CGFloat = 16
        static let requestAvatarCorner: CGFloat = 20

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
        static let avatarPickerSize = CGSize(width: 128, height: 128)
        static let smallIconSize = CGSize(width: 12, height: 12)
        static let iconSize = CGSize(width: 24, height: 24)
        static let mediumIconSize = CGSize(width: 48, height: 48)
        static let largeIconSize = CGSize(width: 128, height: 128)
        static let chatAvatarSize = CGSize(width: 40, height: 40)
        static let thumbSize = CGSize(width: 38, height: 38)
        static let feedAvatarSize = CGSize(width: 48, height: 48)
        static let feedLargeAvatarSize = CGSize(width: 64, height: 64)
        static let feedIconSize = CGSize(width: 32, height: 32)
        static let feedMediumIconSize = CGSize(width: 20, height: 20)
        static let feedSmallIconSize = CGSize(width: 16, height: 16)

        // MARK: Other

        static let feedItemHeight: CGFloat = 52
        static let homeTabBarHeight: CGFloat = 72

        static let scrollContentInset = UIEdgeInsets(top: 0, left: 0, bottom: Self.homeTabBarHeight, right: 0)
        static let chatTextFieldHeight: CGFloat = 44
        static let chatImageSize = CGSize(width: 125, height: 125)
        static let chatRequestAvatarSize = CGSize(width: 80, height: 80)
        static let chatImageBubbleWidth: CGFloat = 200
        static let chatInputImageSize = CGSize(width: 75, height: 75)
        static let refreshContainerPadding: CGFloat = 40
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
            $0.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(Appearance.Colors.whiteText),
                NSAttributedString.Key.font: Appearance.TextStyle.paragraphSmallSemiBold.font
            ]
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
            $0.tintColor = .white
        }
    }

    // MARK: - Fonts

    enum TextStyle {
        case ultraLargeTitle
        case largeTitle
        case h1
        case h2
        case h3
        case title
        case titleSemiBold
        case titleBold
        case titleSmall
        case titleSmallSemiBold
        case titleSmallMedium
        case titleSmallBold
        case paragraph
        case paragraphBold
        case paragraphSemibold
        case paragraphMedium
        case paragraphSmall
        case paragraphSmallSemiBold
        case paragraphSmallMedium
        case paragraphSmallBold
        case description
        case descriptionSemiBold
        case descriptionBold
        case micro

        var font: UIFont {
            switch self {
            case .ultraLargeTitle:
                return R.font.ppMonumentExtendedBold(size: 80) ?? UIFont.systemFont(ofSize: 80, weight: .bold)
            case .largeTitle:
                return R.font.ppMonumentExtendedBold(size: 64) ?? UIFont.systemFont(ofSize: 64, weight: .bold)
            case .h1:
                return R.font.ppMonumentExtendedBold(size: 40) ?? UIFont.systemFont(ofSize: 40, weight: .bold)
            case .h2:
                return R.font.ppMonumentExtendedBold(size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
            case .h3:
                return R.font.ppMonumentExtendedBold(size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
            case .title:
                return R.font.ttSatoshiMedium(size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .regular)
            case .titleSemiBold:
                return R.font.ttSatoshiDemiBold(size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
            case .titleBold:
                return R.font.ttSatoshiBold(size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
            case .titleSmall:
                return R.font.ttSatoshiRegular(size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .regular)
            case .titleSmallSemiBold:
                return R.font.ttSatoshiDemiBold(size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
            case .titleSmallMedium:
                return R.font.ttSatoshiMedium(size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
            case .titleSmallBold:
                return R.font.ttSatoshiBold(size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
            case .paragraph:
                return R.font.ttSatoshiRegular(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
            case .paragraphSemibold:
                return R.font.ttSatoshiDemiBold(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
            case .paragraphBold:
                return R.font.ttSatoshiBold(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
            case .paragraphMedium:
                return R.font.ttSatoshiMedium(size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
            case .paragraphSmall:
                return R.font.ttSatoshiRegular(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
            case .paragraphSmallSemiBold:
                return R.font.ttSatoshiDemiBold(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            case .paragraphSmallMedium:
                return R.font.ttSatoshiMedium(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
            case .paragraphSmallBold:
                return R.font.ttSatoshiBold(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
            case .description:
                return R.font.ttSatoshiRegular(size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
            case .descriptionSemiBold:
                return R.font.ttSatoshiDemiBold(size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
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
