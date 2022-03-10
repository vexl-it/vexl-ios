//
//  RegisterContacts+PhoneView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import SwiftUI
import Cleevio

extension RegisterContactsView {

    struct PhoneContactsView: View {

        @ObservedObject var viewModel: RegisterContactsViewModel.PhoneViewModel

        var body: some View {
            VStack {

                Spacer()

                portraitView

                Text("Looking cute,\nlet’s find you some friends.")
                    .multilineTextAlignment(.center)
                    .textStyle(.h2)
                    .foregroundColor(.white)

                Spacer()

                contactsView
                    .padding(.bottom, Appearance.GridGuide.mediumPadding1)

                SolidButton(Text("Import contacts"),
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
                      primaryButton: Alert.Button.cancel(Text("Cancel"), action: {
                    viewModel.cancel()
                }),
                      secondaryButton: Alert.Button.default(Text("Ok"), action: {
                    viewModel.next()
                }))
            }
        }

        private var portraitView: some View {
            RegisterContactsView.RegisterPortraitsView(name: viewModel.userName,
                                                       avatar: R.image.onboarding.testAvatar()!)
        }

        private var contactsView: some View {
            HStack {
                Image(R.image.onboarding.eye.name)

                Text("vexl doesn’t see your contacts")
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray2)
            }
        }
    }
}

struct RegisterContactsPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.PhoneContactsView(viewModel: RegisterContactsViewModel.PhoneViewModel(userName: "Diego"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
