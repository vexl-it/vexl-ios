//
//  RegistrationView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 08.02.2022.
//

import SwiftUI
import Combine

struct RegistrationView: View {
    @StateObject var viewModel: RegistrationViewModel

    var body: some View {
        VStack {
            Text("Login")
            Button("Dismiss") { viewModel.send(action: .dismissTap) }
        }
    }
}
