//
//  PasswordValidationView.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import SwiftUI
import Combine
import Cleevio

public struct PasswordValidationView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @StateObject var viewModel: PasswordValidationViewModel

    public var body: some View {
        GeometryReader { geometry in
            VStack {
                CLTextField(placeholder: "Password",
                                 text: $viewModel.password,
                                 type: .password)
                    .padding(.horizontal, 16)
                HStack {
                    PasswordRulesView(rules: viewModel.rules)
                        .frame(width: geometry.size.width * 0.8, height: 125)
                    Spacer()
                }
                .padding([.top, .leading], 16)

                Spacer()

                CLButton(
                    buttonTap: viewModel.buttonTap,
                    text: "Continue",
                    isLoading: viewModel.isLoading,
                    isDisabled: viewModel.isContinueDisabled
                )
                .alert(isPresented:
                        Binding<Bool>(
                            get: { self.viewModel.showSuccess },
                            set: { _ in self.viewModel.showSuccess = false }
                        )
                ) {
                    Alert(
                        title: Text("Good"),
                        message: Text("Password looks strong!"),
                        dismissButton: .default(Text("Ok"))
                    )
                }
            }
            .padding(.top, 30)
            .navigationBarTitle(Text("Create password"))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    public init(viewModel: PasswordValidationViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
