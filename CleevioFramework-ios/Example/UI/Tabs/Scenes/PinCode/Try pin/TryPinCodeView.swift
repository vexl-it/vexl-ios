//
//  TryPinCodeView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 2/7/21.
//

import SwiftUI
import Cleevio

struct TryPinCodeView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @StateObject var viewModel: TryPinCodeViewModel

    enum UIProperties {
        static let pinColor = Color(red: 254/255, green: 197/255, blue: 39/255)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(viewModel.title)
                    .font(.system(size: 28, weight: .bold, design: .default))

                Text("Try again")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .padding(.vertical, 10)
                    .opacity(viewModel.state == .missmatch ? 1 : 0)
                    .animation(.easeInOut)

                CLPinCode(
                    keyboardHeight: geometry.size.height * 0.6,
                    maxDigits: viewModel.maxDigits,
                    pinColoredCount: viewModel.getPinColoredCount(),
                    color: UIProperties.pinColor,
                    errorColor: .red,
                    state: viewModel.state,
                    invalidAttempts: viewModel.invalidAttempts,
                    keyTap: viewModel.keyTap,
                    deleteTap: viewModel.deleteTap
                )
                .padding(.vertical, 10)
                .padding(.bottom, 15)
                .alert(isPresented:
                        Binding<Bool>(
                            get: { self.viewModel.pinMatched },
                            set: { _ in
                                self.viewModel.pinMatched = false
                                self.presentation.wrappedValue.dismiss()
                            }
                        )
                ) {
                    Alert(
                        title: Text("Pin match!"),
                        message: Text("You can now use your private info..."),
                        dismissButton: .default(Text("Ok"))
                    )
                }

                Spacer()

                if viewModel.userHaveBiometricSupport {
                    Button {
                        viewModel.evaluateBiometric()
                    } label: {
                        Image(viewModel.biometricImageName)
                    }
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 10)
                }
                
                Button {
                    print("User forgot password...")
                } label: {
                    Text("Forgot your password?")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentation.wrappedValue.dismiss()
        }, label: {
            Image("icBack")
        }))
    }
}
