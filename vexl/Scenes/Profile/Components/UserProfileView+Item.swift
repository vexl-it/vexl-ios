//
//  UserProfileView+Item.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import SwiftUI

extension UserProfileView {
    struct Item: View {

        let title: String
        let subtitle: String?
        let icon: String

        var body: some View {
            HStack(spacing: Appearance.GridGuide.mediumPadding1) {

                Image(icon)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                VStack(alignment: .leading) {
                    Text(title)
                        .textStyle(.paragraph)
                        .foregroundColor(.white)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .textStyle(.micro)
                            .foregroundColor(.white)
                    }
                }
            }
            .listRowBackground(Appearance.Colors.black1)
            .frame(height: Appearance.GridGuide.largeButtonHeight)
            .padding(.vertical, 0)
        }
    }
}
