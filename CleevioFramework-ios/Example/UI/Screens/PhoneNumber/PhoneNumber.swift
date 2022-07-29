//
//  PhoneNumber.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import SwiftUI
import Combine
import Cleevio


struct PhoneNumber: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Fill in and verify your phone number to continue with your registration.")
                    
                    CLPhoneNumberField(placeholder: "Fill in your phone number",
                                       text: $viewModel.phoneNumber)
                }

                Spacer()
            }.padding()

            Spacer()
            CLButton(buttonTap: viewModel.buttonTap, text: "Continue")
        }
        .navigationBarTitle(Text("Phone number"))
    }
}

#if DEBUG
struct PhoneNumber_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhoneNumber(viewModel: .init(dependencies: .preview))
        }
    }
}
#endif
