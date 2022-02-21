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
                ForEach((0..<numberOfPages), id: \.self) { index in
                    Rectangle()
                        .foregroundColor(currentIndex >= index ? Color.white : Color(R.color.gray1.name))
                        .frame(height: 4)
                        .cornerRadius(2)
                        .transition(.opacity)
                        .id(index)
                }
            }
        }
    }
}
