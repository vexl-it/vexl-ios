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
                .padding(.top, GridGuide.largeMargin)

            VStack {
                Text("That’s it, ready to get started?")
                    .font(TextStyle.h2.asFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.horizontal, GridGuide.mediumMargin)

                agreementSwitch
                    .padding(.bottom, GridGuide.largeMargin)
                    .padding(.top, GridGuide.largerMargin)

                LargeButton(title: "Continue",
                            color: ColorGuide.lightPurple,
                            isEnabled: viewModel.hasAgreedTermsAndConditions,
                            action: {
                    viewModel.send(action: .continueTap)
                })
                .padding(.horizontal, GridGuide.padding)
            }.frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var agreementSwitch: some View {
        HStack {
            Toggle("", isOn: $viewModel.hasAgreedTermsAndConditions)
                .labelsHidden()

            Text("I agree to Terms and Privacy")
                .foregroundColor(.white)
                .font(TextStyle.paragraph.asFont)
                .padding(.leading, GridGuide.point)
        }
    }
}

struct LoginViewPreview: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
