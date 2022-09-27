//
//  NotificationPermissionView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.09.2022.
//

import Foundation
import SwiftUI

struct NotificationPermissionView: View {
    @ObservedObject var viewModel: NotificationPermissionViewModel

    var body: some View {
        VStack {
            card
                .padding(.horizontal, Appearance.GridGuide.point)

            LargeSolidButton(title: viewModel.buttonTitle,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.send(action: .enableTap)
            })
            .padding(.horizontal, Appearance.GridGuide.point)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var card: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            HStack {
                Spacer()
                CloseButton(dismissAction: { viewModel.send(action: .close) })
            }
            .padding()

            Spacer()

            Image(R.image.faq7.name)

            Spacer()

            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .textStyle(.h3)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding(.horizontal, Appearance.GridGuide.point)

            Text(viewModel.subtitle)
                .textStyle(.paragraphSmallMedium)
                .foregroundColor(Appearance.Colors.gray2)
                .multilineTextAlignment(.center)
                .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

struct NotificationPermissionViewPreview: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView(viewModel: .init())
    }
}
