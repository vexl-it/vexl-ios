//
//  LoginView.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            Text("Login")
            Button("Dismiss") { viewModel.send(action: .dismissTap) }
            Button("Push to registration") { viewModel.send(action: .showRegistration) }
        }
    }
}
