//
//  RegisterContacts+PhoneView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import SwiftUI
import Cleevio

struct RequestAccessContactsView: View {

    @ObservedObject var viewModel: RequestAccessContactsViewModel

    var body: some View {
        VStack {
            card
                .padding(.horizontal, Appearance.GridGuide.point)

            LargeSolidButton(title: viewModel.importButton,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.action.send(.next)
            })
                .padding(.horizontal, Appearance.GridGuide.point)

            if viewModel.displaySkipButton {
                LargeSolidButton(title: L.registerContactsSkip(),
                                 font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                 style: .custom(color: .skip),
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: {
                    viewModel.action.send(.skip)
                })
                    .padding(.horizontal, Appearance.GridGuide.point)
            }
        }
    }

    private var card: some View {
        VStack {
            Image(data: viewModel.image, placeholder: "")
                .resizable()
                .scaledToFit()
                .padding(Appearance.GridGuide.mediumPadding1)

            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .textStyle(.h3)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding(.horizontal, Appearance.GridGuide.point)

            HStack {
                Image(R.image.onboarding.eye.name)

                Text(viewModel.subtitle)
                    .textStyle(.paragraphSmallMedium)
                    .foregroundColor(Appearance.Colors.gray2)
            }
            .padding(.bottom, Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

struct RequestAccessContactsViewPreview: PreviewProvider {
    static var previews: some View {
        RequestAccessContactsView(viewModel: RequestAccessFacebookContactsViewModel(activity: .init(indicator: nil, error: nil)))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewDevice("iPhone 11")
    }
}
