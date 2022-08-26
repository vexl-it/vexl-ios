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
    let subtitlePositionIsBottom: Bool
    let iconName: String?
    let bottomPadding: CGFloat
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {

            Text(title)
                .textStyle(.h3)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding([.top, .horizontal], Appearance.GridGuide.point)
                .fixedSize(horizontal: false, vertical: true)

            if !subtitlePositionIsBottom {
                subtitleView
            }

            content()

            if subtitlePositionIsBottom {
                subtitleView
            }
        }
        .padding(.all, Appearance.GridGuide.padding)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CardViewModifier())
    }

    private var subtitleView: some View {
        HStack {
            if let iconName = iconName {
                Image(iconName)
            }

            Text(subtitle)
                .foregroundColor(Appearance.Colors.gray2)
                .textStyle(.description)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
        }
        .padding(.top, Appearance.GridGuide.point)
    }
}

struct RegistrationCardViewPreview: PreviewProvider {
    static var previews: some View {

        let title = "Hello World"
        let subtitle = "This is a subtitle"
        let text = Text("Text goes here")

        RegistrationCardView(title: title,
                             subtitle: subtitle,
                             subtitlePositionIsBottom: true,
                             iconName: R.image.onboarding.eye.name,
                             bottomPadding: Appearance.GridGuide.padding,
                             content: {
            text
        })
            .background(Color.black)

        RegistrationCardView(title: title,
                             subtitle: subtitle,
                             subtitlePositionIsBottom: false,
                             iconName: nil,
                             bottomPadding: Appearance.GridGuide.padding,
                             content: {
            text
        })
            .background(Color.black)
    }
}
