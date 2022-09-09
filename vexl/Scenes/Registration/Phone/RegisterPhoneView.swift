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
    private let transition = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .scale).combined(with: .opacity)

    var body: some View {
        VStack {
            Group {
                if viewModel.showCodeInput {
                    RegisterPhoneCodeInputView(phoneNumber: viewModel.phoneSubtitle,
                                               isEnabled: viewModel.codeInputEnabled,
                                               remainingTime: viewModel.countdown,
                                               displayRetry: viewModel.currentState != .codeInputSuccess,
                                               code: $viewModel.validationCode,
                                               retryAction: {
                        viewModel.send(action: .sendCode)
                    })
                } else {
                    RegisterPhoneNumberInputView(text: $viewModel.phoneNumber,
                                                 regionCode: viewModel.currentRegionCode,
                                                 phoneNumber: viewModel.currentPhoneNumber)
                }
            }
            .padding(.all, Appearance.GridGuide.point)
            .transition(transition)

            Spacer()

            LargeSolidButton(title: viewModel.actionTitle,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: $viewModel.isActionEnabled,
                             action: {
                viewModel.send(action: viewModel.showCodeInput ? .validateCode : .sendPhoneNumber)
            })
                .padding([.horizontal, .bottom], Appearance.GridGuide.point)
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
