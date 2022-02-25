//
//  RegistrationCardView.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Combine

struct RegistrationCardView<Content: View>: View {

    let title: String
    let subtitle: String
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .textStyle(.h2)

            Text(subtitle)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray2)
                .padding(.top, 24)

            content
        }
        .padding(.all, Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardViewModifier())
    }
}
