//
//  PhoneNumber.swift
//  CleevioUI
//
//  Created by Diego on 25/12/21.
//

import SwiftUI
import Combine
import Cleevio

public struct PhoneNumberView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    public var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                    CLPhoneNumberField(placeholder: viewModel.placeholder,
                                       text: $viewModel.phoneNumber)
                }

                Spacer()
            }.padding()

            Spacer()
            CLButton(buttonTap: viewModel.buttonTap, text: "Continue")
        }
        .navigationBarTitle(Text("Phone number"))
    }
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension PhoneNumberView {
    
    public class ViewModel: ObservableObject {
        
        let title: String
        let placeholder: String
        
        private(set) var buttonTap = PassthroughSubject<Void, Never>()
        
        @Published var phoneNumber: String = ""
        
        public init(title: String, placeholder: String) {
            self.title = title
            self.placeholder = placeholder
        }
    }
    
}
