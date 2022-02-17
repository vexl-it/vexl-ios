//
//  LoginView.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import SwiftUI
import Combine
import Cleevio

struct LoginView: View {

    @StateObject var viewModel: LoginViewModel

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .edgesIgnoringSafeArea(.vertical)

            LoginLogoView()
                .padding(.top, Appearance.GridGuide.largePadding)

            VStack {
                Text("That’s it, ready to get started?")
                    .font(Appearance.TextStyle.h2.asFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.horizontal, Appearance.GridGuide.mediumPadding)

                agreementSwitch
                    .padding(.bottom, Appearance.GridGuide.largePadding)
                    .padding(.top, Appearance.GridGuide.largePadding)

                LargeButton(title: "Continue",
                            backgroundColor: Appearance.Colors.purple5,
                            isEnabled: viewModel.hasAgreedTermsAndConditions,
                            action: {
                    viewModel.send(action: .continueTap)
                })
                    .padding(.horizontal, Appearance.GridGuide.padding)
            }.frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var agreementSwitch: some View {
        HStack {
            Toggle("", isOn: $viewModel.hasAgreedTermsAndConditions)
                .labelsHidden()

            Text("I agree to Terms and Privacy")
                .foregroundColor(.white)
                .font(Appearance.TextStyle.paragraph.asFont)
                .padding(.leading, Appearance.GridGuide.point)
        }
    }
}

struct LoginViewPreview: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
