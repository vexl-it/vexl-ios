//
//  UserProfileView+Item.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import SwiftUI

extension UserProfileView {
    enum TitleType {
        case normal(String)
        case attributed(NSAttributedString)
    }

    struct Item: View {

        let titleType: TitleType
        let subtitle: String?
        let icon: String
        let type: UserProfileView.OptionType

        var body: some View {
            HStack(spacing: Appearance.GridGuide.mediumPadding1) {

                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(size: Appearance.GridGuide.iconSize)

                VStack(alignment: .leading) {
                    titleView
                        .foregroundColor(type.color)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .textStyle(.micro)
                            .foregroundColor(.white)
                    }
                }
            }
            .background(Appearance.Colors.black1)
            .frame(height: Appearance.GridGuide.largeButtonHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 0)
        }

        @ViewBuilder
        private var titleView: some View {
            switch titleType {
            case .normal(let title):
                Text(title)
                    .textStyle(.paragraph)
            case .attributed(let attributedTitle):
                AttributedText(attributedText: attributedTitle, color: UIColor(type.color))
            }
        }
    }
}
