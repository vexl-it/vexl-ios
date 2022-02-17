//
//  OnboardingView.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI
import Combine

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    // MARK: Onboarding Pages

    private var pages: [AnyView] {
        [AnyView(PageOne()),
         AnyView(PageTwo()),
         AnyView(PageThree())]
    }

    private var numberOfPages: Int {
        pages.count
    }

    var body: some View {

        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.vertical)

            VStack {
                PageControl(numberOfPages: numberOfPages, currentIndex: $viewModel.selectedIndex)

                TabView(selection: $viewModel.selectedIndex) {
                    ForEach((0..<numberOfPages), id: \.self) { index in
                        pages[index]
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never ))
                .onChange(of: viewModel.selectedIndex) { newValue in
                    viewModel.selectedIndex = newValue
                }

                HStack {
                    LargeButton(title: "Skip",
                                backgroundColor: Appearance.Colors.gray1,
                                textColor: Appearance.Colors.gray3,
                                isEnabled: true) {
                        viewModel.send(action: .skip)
                    }
                    LargeButton(title: "Next",
                                backgroundColor: Appearance.Colors.purple5,
                                isEnabled: false) {
                        guard viewModel.selectedIndex < numberOfPages else { return }
                        viewModel.send(action: .next)
                    }
                }
            }
        }
    }
}

struct OnboardingViewPreview: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}

struct PageOne: View {
    var body: some View {
        Text("1")
    }
}

struct PageTwo: View {
    var body: some View {
        Text("2")
    }
}

struct PageThree: View {
    var body: some View {
        Text("3")
    }
}
