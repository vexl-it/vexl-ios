//
//  RegisterPhoneView.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import Foundation
import SwiftUI
import Cleevio

struct RegisterPhoneView: View {

    @ObservedObject var viewModel: RegisterPhoneViewModel

    var body: some View {
        VStack {

            if viewModel.currentState == .codeInput {
                CodeInputView(code: $viewModel.validationCode)
                    .padding(.all, Appearance.GridGuide.point)
            } else if viewModel.currentState == .phoneInput {
                PhoneInputView(phoneNumber: $viewModel.phoneNumber)
                    .padding(.all, Appearance.GridGuide.point)
            }

            Spacer()

            SolidButton(Text("Continue"),
                        isEnabled: $viewModel.isContinueEnabled,
                        fullWidth: true,
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton) {
                viewModel.send(action: .nextTap)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.bottom, Appearance.GridGuide.padding)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RegisterPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView(viewModel: .init())
    }
}
