//
//  PhoneNumberView.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI
import Cleevio

struct PhoneNumberSceneContainerView: View, Content {
    
    var name: String { "Phone Number" }
    var view: AnyView { AnyView(self) }

    private var viewModel: PhoneNumberView.ViewModel {
        PhoneNumberView.ViewModel(title: "Fill in and verify your phone number to continue with your registration.",
                                  placeholder: "Fill in your phone number")
    }
    
    var body: some View {
        PhoneNumberView(viewModel: viewModel)
    }
    
}
