//
//  RegistrationCardView.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Combine

struct RegistrationCardView<Content>: View where Content: View {

    let title: String
    let subtitle: String
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {

            RegistrationCardTitleView(title: title,
                                      subtitle: subtitle)

            content
        }
        .padding(.all, Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardViewModifier())
    }
}

struct RegistrationHeaderCardView<Header, Content>: View where Header: View, Content: View {

    let title: String
    let subtitle: String
    let header: Header
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {

            header

            RegistrationCardTitleView(title: title,
                                      subtitle: subtitle)

            content
        }
        .padding(.all, Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardViewModifier())
    }
}

private struct RegistrationCardTitleView: View {

    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            Text(title)
                .textStyle(.h2)

            Text(subtitle)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray2)
                .padding(.top, Appearance.GridGuide.mediumPadding1)
        }
    }
}
