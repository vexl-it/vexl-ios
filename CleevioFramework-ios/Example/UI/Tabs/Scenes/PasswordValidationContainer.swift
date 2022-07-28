//
//  PasswordValidationView.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI

struct PasswordValidationSceneContainerView: View, Content {
    
    var name: String { "Password Validation" }
    var view: AnyView { AnyView(self) }
    
    private var viewModel: PasswordValidationViewModel {
        PasswordValidationViewModel()
    }
    
    var body: some View {
        PasswordValidationView(viewModel: viewModel)
    }
    
}
