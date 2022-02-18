//
//  OnboardingView.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI
import Combine
import Cleevio

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    // MARK: Onboarding Pages

    private let skipWidth: CGFloat = 87

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

                HStack(alignment: .center) {
                    SolidButton(Text("Skip"),
                                font: Appearance.TextStyle.h3.font.asFont,
                                colors: SolidButtonColor.skip,
                                dimensions: SolidButtonDimension.largeButton,
                                action: {
                        viewModel.send(action: .skip)
                    })
                    .frame(width: skipWidth)

                    SolidButton(Text("Next"),
                                isEnabled: .constant(false),
                                font: Appearance.TextStyle.h3.font.asFont,
                                colors: SolidButtonColor.welcome,
                                dimensions: SolidButtonDimension.largeButton,
                                action: {
                        guard viewModel.selectedIndex < numberOfPages - 1 else { return }
                        viewModel.send(action: .next)
                    })
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
            .foregroundColor(.white)
    }
}

struct PageTwo: View {
    var body: some View {
        Text("2")
            .foregroundColor(.white)
    }
}

struct PageThree: View {
    var body: some View {
        Text("3")
            .foregroundColor(.white)
    }
}
