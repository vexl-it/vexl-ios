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
        ZStack {

            if let error = viewModel.error {
                Text(error.getMessage())
                    .foregroundColor(Color.white)
                    .background(Color.red)
                    .frame(width: 50, height: 50)
            }

            if viewModel.loading {
                LoadingIndicatorView()
            }

            VStack {

                if viewModel.showCodeInput {
                    CodeInputView(phoneNumber: viewModel.phoneNumber,
                                  isEnabled: viewModel.codeInputEnabled,
                                  remainingTime: viewModel.countdown,
                                  code: $viewModel.validationCode,
                                  retryAction: {
                        viewModel.send(action: .sendCode)
                    })
                        .padding(.all, Appearance.GridGuide.point)
                } else {
                    PhoneInputView(phoneNumber: $viewModel.phoneNumber)
                        .padding(.all, Appearance.GridGuide.point)
                }

                Spacer()

                SolidButton(Text(viewModel.actionTitle),
                            isEnabled: $viewModel.isActionEnabled,
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: viewModel.actionColor,
                            dimensions: SolidButtonDimension.largeButton) {
                    viewModel.send(action: .nextTap)
                }
                .padding(.horizontal, Appearance.GridGuide.padding)
                .padding(.bottom, Appearance.GridGuide.padding)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RegisterPhoneViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView(viewModel: .init())
    }
}
