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
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.vertical)

            VStack {
                Color.red
                    .frame(height: 350)

                Spacer()

                Text("That’s it, ready to get started?")
                    .font(TextStyle.h2.asFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .padding(.horizontal, GridGuide.mediumMargin)

                agreementSwitch
                    .padding(.bottom, 50)
                    .padding(.top, 82)

                LargeButton(title: "Continue",
                            color: ColorGuide.lightPurple,
                            isEnabled: viewModel.hasAgreedTermsAndConditions,
                            action: {
                    viewModel.send(action: .continueTap)
                })
                .padding(.horizontal, GridGuide.padding)
            }
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
