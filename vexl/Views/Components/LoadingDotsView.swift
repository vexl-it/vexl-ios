//
//  LoadingDotsView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.05.2022.
//

import SwiftUI

struct LoadingDotsView: View {
    let dotCount: Int
    let dotDiameter: CGFloat
    let spacing: CGFloat
    let color: Color
    private let animationDuration = 0.5

    init(dotCount: Int = 3, dotDiameter: CGFloat = 10, color: Color = Appearance.Colors.whiteText) {
        self.dotCount = dotCount
        self.dotDiameter = dotDiameter
        self.spacing = dotDiameter
        self.color = color
    }

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< dotCount, id: \.self) { index in
                Circle()
                    .foregroundColor(color)
                    .frame(width: dotDiameter, height: dotDiameter)
                    .opacity(isAnimating ? 0.2 : 1)
                    .transaction { tr in
                        tr.animation = Animation
                            .easeInOut(duration: animationDuration)
                            .repeatForever(autoreverses: true)
                            .delay(animationDuration * (Double(index) / Double(dotCount)))
                    }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
