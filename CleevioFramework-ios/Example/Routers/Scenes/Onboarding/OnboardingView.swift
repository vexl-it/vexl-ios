//
//  OnboardingView.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI
import Combine

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack {
            Text("Onboarding screen")
            Button("Push login screen") { viewModel.send(action: .tapLogin) }
            Button("Present modal") { viewModel.send(action: .tapPresentModal) }
        }
    }
}
