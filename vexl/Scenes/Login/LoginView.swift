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
                title
                    .padding(.horizontal, Appearance.GridGuide.mediumPadding)

                AgreementSwitch(text: "I agree to Terms and Privacy",
                                links: ["Terms and Privacy": "https://google.com"],
                                isOn: $viewModel.hasAgreedTermsAndConditions)
                    .padding(.horizontal, Appearance.GridGuide.largePadding)
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

    private var title: some View {
        Text("That’s it, ready to get started?")
            .font(Appearance.TextStyle.h2.asFont)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .lineLimit(2)
    }
}

struct LoginViewPreview: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
