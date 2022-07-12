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
    let iconName: String?
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {

            RegistrationCardTitleView(title: title,
                                      subtitle: subtitle,
                                      iconName: iconName)

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
    let iconName: String?
    let header: Header
    let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {

            header

            RegistrationCardTitleView(title: title,
                                      subtitle: subtitle,
                                      iconName: iconName)

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
    let iconName: String?

    var body: some View {
        VStack(alignment: .leading,
               spacing: Appearance.GridGuide.point) {
            Text(title)
                .textStyle(.h3)
                .foregroundColor(Appearance.Colors.primaryText)

            HStack {
                if let iconName = iconName {
                    Image(iconName)
                }

                Text(subtitle)
                    .foregroundColor(Appearance.Colors.gray2)
                    .textStyle(.paragraph)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            .padding(.top, Appearance.GridGuide.mediumPadding1)
        }
    }
}

struct RegistrationCardViewPreview: PreviewProvider {
    static var previews: some View {

        let title = "Hello World"
        let subtitle = "This is a subtitle"
        let text = Text("Text goes here")
        let header = Text("Header goes here")

        RegistrationHeaderCardView(title: title,
                                   subtitle: subtitle,
                                   iconName: R.image.onboarding.eye.name,
                                   header: header,
                                   content: text)

        RegistrationCardView(title: title,
                             subtitle: subtitle,
                             iconName: nil,
                             content: text)
    }
}
