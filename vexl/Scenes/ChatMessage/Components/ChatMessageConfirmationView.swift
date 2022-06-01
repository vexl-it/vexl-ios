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
                SolidButton(Text(actionTitle),
                            iconImage: nil,
                            isEnabled: .constant(true),
                            isLoading: .constant(false),
                            fullWidth: true,
                            loadingViewScale: 1,
                            font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                            colors: .main,
                            dimensions: .largeButton,
                            action: {
                    mainAction()
                })

                SolidButton(Text(dismissTitle),
                            iconImage: nil,
                            isEnabled: .constant(true),
                            isLoading: .constant(false),
                            fullWidth: true,
                            loadingViewScale: 1,
                            font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                            colors: .main,
                            dimensions: .largeButton,
                            action: {
                    dismiss()
                })
            }
        }
        .padding(Appearance.GridGuide.point)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

struct ChatMessageConfirmationViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageConfirmationView(title: "Delete chat?",
                                    subtitle: "Are you sure you want to delete the chat bla bla bla?",
                                    actionTitle: "Delete Chat",
                                    dismissTitle: "Back",
                                    mainAction: { },
                                    dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
