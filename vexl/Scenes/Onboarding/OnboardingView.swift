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
            Text("Onboarding")
            Button("Push") { viewModel.send(action: .tap) }
        }
    }
}

struct OnboardingViewPreview: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}
