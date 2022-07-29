//
//  LoadingView.swift
//  CleevioUI
//
//  Created by Diego on 10/01/22.
//

import Foundation
import SwiftUI

public struct LoadingView: View {
    var scale: CGFloat
    var spacing: CGFloat
    var dotDiameter: CGFloat
    var dotCount: Int
    var circleColor: Color

    private var calculatedWidth: CGFloat { (CGFloat(dotCount) * dotDiameter) + (CGFloat(dotCount - 1) * spacing) }
    private let animationDuration: CGFloat = 0.5

    @State private var isAnimating: Bool = false

    public init(scale: CGFloat = 1,
                spacing: CGFloat = 10,
                dotDiameter: CGFloat = 10,
                dotCount: Int = 3,
                circleColor: Color = .white) {
        self.scale = scale
        self.spacing = spacing
        self.dotDiameter = dotDiameter
        self.dotCount = dotCount
        self.circleColor = circleColor
    }
    
    public var body: some View {
        VStack {
            HStack(spacing: spacing) {
                ForEach(0 ..< dotCount, id: \.self) { index in
                    Circle()
                        .foregroundColor(circleColor)
                        .opacity(isAnimating ? 0.2 : 1)
                        .animation(
                            Animation
                                .easeInOut(duration: animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(animationDuration * (Double(index) / Double(dotCount)))
                        )
                }
            }
            .frame(width: calculatedWidth, height: dotDiameter, alignment: .center)
            .scaleEffect(.init(scale))
            .frame(minWidth: calculatedWidth, maxWidth: .infinity, minHeight: dotDiameter, maxHeight: .infinity)
            .onAppear {
                isAnimating = true
            }

        }
    }
}
