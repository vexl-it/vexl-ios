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

            if viewModel.showCodeInput {
                CodeInputView(phoneNumber: viewModel.phoneNumber,
                              isEnabled: viewModel.codeInputEnabled,
                              remainingTime: viewModel.countdown,
                              displayRetry: viewModel.currentState != .codeInputSuccess,
                              code: $viewModel.validationCode,
                              retryAction: {
                    viewModel.send(action: .sendCode)
                })
                    .padding(.all, Appearance.GridGuide.point)
            } else {
                PhoneInputView(phoneNumber: $viewModel.phoneNumber) {
                    // TODO: - implement country picker once its done
                }
                    .padding(.all, Appearance.GridGuide.point)
            }

            Spacer()

            SolidButton(Text(viewModel.actionTitle),
                        isEnabled: $viewModel.isActionEnabled,
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: viewModel.actionColor,
                        dimensions: SolidButtonDimension.largeButton) {
                viewModel.send(action: viewModel.showCodeInput ? .validateCode : .sendPhoneNumber)
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
