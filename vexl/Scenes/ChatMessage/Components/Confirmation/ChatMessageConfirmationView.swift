//
//  ChatMessageConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 1/06/22.
//

import SwiftUI
import Cleevio

struct ChatMessageConfirmationView: View {

    let title: String
    let subtitle: String
    let actionTitle: String
    let dismissTitle: String
    let primaryColor: LargeSolidButton.Style
    let secondaryColor: LargeSolidButton.Style
    let mainAction: () -> Void
    let dismiss: () -> Void

    private let screenHeight: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: .zero) {
                Text(title)
                    .textStyle(.h2)

                Text(subtitle)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray3)
                    .padding(.vertical, Appearance.GridGuide.padding)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .frame(maxWidth: .infinity, minHeight: screenHeight * 0.33, alignment: .bottomLeading)
            .background(Appearance.Colors.whiteText)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            HStack {
                LargeSolidButton(title: dismissTitle,
                                 font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                                 style: secondaryColor,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: dismiss)

                LargeSolidButton(title: actionTitle,
                                 font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                                 style: primaryColor,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: mainAction)
            }
        }
        .padding(Appearance.GridGuide.point)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

extension ChatMessageConfirmationView {
    enum Style {
        case regular
        case block
    }
}

struct ChatMessageConfirmationViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageConfirmationView(title: "Delete chat?",
                                    subtitle: "Are you sure you want to delete the chat bla bla bla?",
                                    actionTitle: "Delete Chat",
                                    dismissTitle: "Back",
                                    primaryColor: .main,
                                    secondaryColor: .secondary,
                                    mainAction: { },
                                    dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")

        ChatMessageConfirmationView(title: "Block chat?",
                                    subtitle: "Are you sure you want to block the chat bla bla bla?",
                                    actionTitle: "Block Chat",
                                    dismissTitle: "Back",
                                    primaryColor: .red,
                                    secondaryColor: .redSecondary,
                                    mainAction: { },
                                    dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
