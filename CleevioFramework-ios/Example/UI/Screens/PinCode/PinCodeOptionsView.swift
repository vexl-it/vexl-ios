//
//  PinCodeOptionsView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 1/11/21.
//

import SwiftUI

enum PinCodeOption: String, CaseIterable {
    case create
    case tryIt
    case delete

    var title: String {
        switch self {
        case .create:
            return "Create your pin code"
        case .tryIt:
            return "Try pin code"
        case .delete:
            return "Delete pin code"
        }
    }
}

public struct PinCodeOptionsView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @StateObject var viewModel: PinCodeOptionsViewModel

    public var body: some View {
        List {
            if !viewModel.isPinSaved {
                NavigationLink(
                    PinCodeOption.create.title,
                    destination: CreatePinCodeView(
                        viewModel: CreatePinCodeViewModel(reloadOptionsView: viewModel.reload)
                    )
                )
            }

            if viewModel.isPinSaved {
                NavigationLink(PinCodeOption.tryIt.title, destination: TryPinCodeView(viewModel: TryPinCodeViewModel()))
            }

            if viewModel.isPinSaved {
                Button {
                    viewModel.deleteSavedPin()
                } label: {
                    Text(PinCodeOption.delete.title)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(.red)
                }
                .alert(isPresented:
                        Binding<Bool>(
                            get: { self.viewModel.pinDeleted },
                            set: { _ in
                                self.viewModel.pinDeleted = false
                            }
                        )
                ) {
                    Alert(
                        title: Text("Pin deleted"),
                        message: Text("You can always create more pins!"),
                        dismissButton: Alert.Button.default(Text("Ok"), action: {
                            self.viewModel.isPinSaved = false
                        })
                    )
                }
            }
        }
        .navigationBarTitle(Text("Pin code options"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentation.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "chevron.left")
        }))
    }
    
    public init(viewModel: PinCodeOptionsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
