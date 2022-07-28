//
//  CreatePinCodeView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 1/11/21.
//

import SwiftUI
import Cleevio

public struct CreatePinCodeView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @StateObject var viewModel: CreatePinCodeViewModel

    public init(viewModel: CreatePinCodeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    enum UIProperties {
        static let pinColor = Color(red: 254/255, green: 197/255, blue: 39/255)
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(viewModel.title)
                    .font(.system(size: 28, weight: .bold, design: .default))

                Text("Please create code again")
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

                Spacer()

                Button {
                    print("Need help!")
                } label: {
                    Text("Need help?")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(.black)
                }
                .padding(.bottom, 30)
                .alert(isPresented:
                        Binding<Bool>(
                            get: { self.viewModel.pinCreatedWithSuccess },
                            set: { _ in
                                self.viewModel.pinCreatedWithSuccess = false
                                self.presentation.wrappedValue.dismiss()
                            }
                        )
                ) {
                    Alert(
                        title: Text("Pin match!"),
                        message: Text("We saved your pin for later use!"),
                        dismissButton: .default(Text("Ok"))
                    )
                }
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
