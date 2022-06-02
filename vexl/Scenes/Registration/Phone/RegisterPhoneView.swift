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

            LargeSolidButton(title: viewModel.actionTitle,
                             font: Appearance.TextStyle.h3.font.asFont,
                             style: .custom(color: viewModel.actionColor),
                             isFullWidth: true,
                             isEnabled: $viewModel.isActionEnabled,
                             action: {
                viewModel.send(action: viewModel.showCodeInput ? .validateCode : .sendPhoneNumber)
            })
                .padding(.horizontal, Appearance.GridGuide.padding)
                .padding(.bottom, Appearance.GridGuide.padding)
                .transaction { $0.disablesAnimations = true }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .animation(.easeInOut(duration: 0.5), value: viewModel.showCodeInput)
    }
}

struct RegisterPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView(viewModel: .init())
    }
}
