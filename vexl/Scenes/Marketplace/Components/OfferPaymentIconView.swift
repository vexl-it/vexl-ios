//
//  MarketplaceFeedPaymentIconView.swift
//  vexl
//
//  Created by Diego Espinoza on 25/05/22.
//

import SwiftUI

struct OfferPaymentIconView: View {

    let layoutStyle: LayoutStyle

    var body: some View {
        switch layoutStyle {
        case .none:
            Text(Constants.notAvailable)
                .textStyle(.descriptionBold)
                .foregroundColor(Appearance.Colors.gray3)
        case let .single(icon):
            Image(icon)
                .resizable()
                .frame(size: Appearance.GridGuide.feedIconSize)
        case let .double(first, second):
            HStack(spacing: Appearance.GridGuide.tinyPadding) {
                Image(first)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedMediumIconSize)
                Image(second)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedMediumIconSize)
            }
        case let .triple(first, second, third):
            VStack(spacing: Appearance.GridGuide.tinyPadding) {
                Image(first)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedSmallIconSize)
                HStack(spacing: Appearance.GridGuide.tinyPadding) {
                    Image(second)
                        .resizable()
                        .frame(size: Appearance.GridGuide.feedSmallIconSize)
                    Image(third)
                        .resizable()
                        .frame(size: Appearance.GridGuide.feedSmallIconSize)
                }
            }
        }
    }
}

extension OfferPaymentIconView {

    enum LayoutStyle {
        case none
        case single(String)
        case double(String, String)
        case triple(String, String, String)

        init(icons: [String]) {
            switch icons.count {
            case 1:
                self = .single(icons[0])
            case 2:
                self = .double(icons[0], icons[1])
            case 3:
                self = .triple(icons[0], icons[1], icons[2])
            default:
                self = .none
            }
        }
    }
}
