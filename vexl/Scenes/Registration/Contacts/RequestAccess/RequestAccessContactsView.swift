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

            Spacer()

            portraitView

            Text(viewModel.title)
                .multilineTextAlignment(.center)
                .textStyle(.h2)
                .foregroundColor(.white)

            Spacer()

            contactsView
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)

            SolidButton(Text(viewModel.importButton),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton) {
                viewModel.action.send(.next)
            }
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)

            if viewModel.displaySkipButton {
                SolidButton(Text(L.registerContactsSkip()),
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: SolidButtonColor.skip,
                            dimensions: SolidButtonDimension.largeButton) {
                    viewModel.action.send(.skip)
                }
                .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
            }
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  primaryButton: Alert.Button.cancel(Text(L.generalCancel()), action: {
                viewModel.action.send(.cancel)
            }),
                  secondaryButton: Alert.Button.default(Text(L.generalOk()), action: {
                viewModel.action.send(.next)
            }))
        }
    }

    private var portraitView: some View {
        RequestAccessPortraitView(name: viewModel.username,
                                  avatar: R.image.onboarding.testAvatar()!,
                                  color: viewModel.portraitColor,
                                  textColor: viewModel.portraitTextColor)
    }

    private var contactsView: some View {
        HStack {
            Image(R.image.onboarding.eye.name)

            Text(viewModel.subtitle)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray2)
        }
    }
}

struct RegisterContactsPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RequestAccessContactsView(viewModel: .init(username: "Diego"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
