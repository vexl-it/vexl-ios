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

            Text(L.registerPhoneContactsTitle())
                .multilineTextAlignment(.center)
                .textStyle(.h2)
                .foregroundColor(.white)

            Spacer()

            contactsView
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)

            SolidButton(Text(L.registerContactsImportButton()),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton) {
                viewModel.next()
            }
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title),
                  message: Text(alert.message),
                  primaryButton: Alert.Button.cancel(Text(L.generalCancel()), action: {
                viewModel.cancel()
            }),
                  secondaryButton: Alert.Button.default(Text(L.generalOk()), action: {
                viewModel.next()
            }))
        }
    }

    private var portraitView: some View {
        RequestAccessContactsView.RegisterPortraitsView(name: viewModel.userName,
                                                        avatar: R.image.onboarding.testAvatar()!)
    }

    private var contactsView: some View {
        HStack {
            Image(R.image.onboarding.eye.name)

            Text(L.registerPhoneContactsSubtitle())
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray2)
        }
    }
}

struct RegisterContactsPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RequestAccessContactsView(viewModel: .init(userName: "Diego"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
