//
//  OnboardingView+PageControl.swift
//  vexl
//
//  Created by Diego Espinoza on 17/02/22.
//

import SwiftUI

extension OnboardingView {

    struct PageControl: View {

        let numberOfPages: Int
        @Binding var currentIndex: Int

        var body: some View {
            HStack {
                ForEach(0 ..< numberOfPages, id: \.self) { index in
                    HLine(color: currentIndex >= index ? Color.white : Color(R.color.gray1.name),
                          height: 4)
                        .frame(height: 4)
                        .cornerRadius(2)
                        .transition(.opacity)
                }
            }
        }
    }
}

#if DEBUG || DEVEL

struct OnboardingPageControlPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            OnboardingView.PageControl(numberOfPages: 3,
                                       currentIndex: .constant(1))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#endif
