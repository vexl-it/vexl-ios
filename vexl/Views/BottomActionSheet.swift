//
//  BottomSheet.swift
//  vexl
//
//  Created by Adam Salih on 23.06.2022.
//

import SwiftUI
import Cleevio

struct BottomActionSheet<ContentView: View>: View {
    struct Action {
        var title: String
        var imageName: String?
        var isDismissAction: Bool
        var action: (() -> Void)?

        mutating func inject(dismissAction: @escaping () -> Void) {
            guard isDismissAction else { return }
            let prevAction = self.action
            self.action = {
                dismissAction()
                prevAction?()
            }
        }
    }

    enum ColorScheme {
        case main
        case red

        var primaryButtonStyle: LargeSolidButton.Style {
            switch self {
            case .main:
                return .main
            case .red:
                return .red
            }
        }

        var secondaryButtonStyle: LargeSolidButton.Style {
            switch self {
            case .main:
                return .secondary
            case .red:
                return .redSecondary
            }
        }
    }

    var imageName: String?
    var title: String
    var titleAlignment: Alignment = .leading

    var primaryAction: Action
    var secondaryAction: Action?

    var colorScheme: ColorScheme = .main

    @ViewBuilder var content: () -> ContentView

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {
                if let imageName = imageName {
                    VStack(alignment: .center) {
                        Image(imageName)
                            .resizable()
                            .frame(size: Appearance.GridGuide.largeIconSize)
                            .frame(alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                }
                Text(title)
                    .textStyle(.h2)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: titleAlignment)

                content()
            }
            .padding(.top, Appearance.GridGuide.mediumPadding1)
            .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Appearance.Colors.whiteText)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            HStack {
                if let secondaryAction = secondaryAction {
                    LargeSolidButton(
                        title: secondaryAction.title,
                        font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                        style: colorScheme.secondaryButtonStyle,
                        isFullWidth: true,
                        isEnabled: .constant(true),
                        action: secondaryAction.action ?? {}
                    )
                }
                LargeSolidButton(
                    title: primaryAction.title,
                    font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                    style: colorScheme.primaryButtonStyle,
                    isFullWidth: true,
                    isEnabled: .constant(true),
                    action: primaryAction.action ?? {}
                )
            }
        }
        .padding(Appearance.GridGuide.point)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        BottomActionSheet(
            title: "String",
            primaryAction: .init(title: "title", isDismissAction: false, action: {}),
            secondaryAction: .init(title: "title", isDismissAction: false, action: {}),
            colorScheme: .main,
            content: {
                OfferInformationDetailView(
                    data: .stub,
                    useInnerPadding: true,
                    showBackground: false
                )
                .background(Appearance.Colors.gray6)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .previewDevice("iPhone 11")
    }
}
