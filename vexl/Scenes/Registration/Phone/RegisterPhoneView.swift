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
        AlertContainerView(error: $viewModel.error) {
            LoadingContainerView(loading: viewModel.loading) {
                ContentView(viewModel: viewModel)
            }
        }
    }
}

extension RegisterPhoneView {

    private struct ContentView: View {

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
                    Spacer()
                    actionButton {
                        viewModel.send(action: .validateCode)
                    }
                } else {
                    PhoneInputView(phoneNumber: $viewModel.phoneNumber)
                        .padding(.all, Appearance.GridGuide.point)
                    Spacer()
                    actionButton {
                        viewModel.send(action: .sendPhoneNumber)
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }

        @ViewBuilder private func actionButton(with action: @escaping () -> Void) -> some View {
            SolidButton(Text(viewModel.actionTitle),
                        isEnabled: $viewModel.isActionEnabled,
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: viewModel.actionColor,
                        dimensions: SolidButtonDimension.largeButton) {
                action()
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.bottom, Appearance.GridGuide.padding)
        }
    }
}

struct RegisterPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView(viewModel: .init())
    }
}
