//
//  CircleProgressView.swift
//
//  Created by Thành Đỗ Long on 06.12.2021.
//

import SwiftUI
import Combine

public struct CircleProgressView<Strategy: CircularProgressBarStategyType>: View {
    @ObservedObject public var strategy: Strategy
    @ObservedObject public var appereance: CircleProgressAppearance
    
    public init(strategy: Strategy,
                appereance: CircleProgressAppearance = .default) {
        guard strategy.progressStart < strategy.progressEnd else {
            fatalError("Progress start must be lower than progress end")
        }
        
        self.strategy = strategy
        self.appereance = appereance
    }
    
    public var body: some View{
        Circle()
            .stroke(appereance.backgroundCircleColor,
                    style: appereance.backgroundCircleStyle)
            .overlay(overlayCircle)
            .background(text)
            .padding(appereance.padding.edges, appereance.padding.length)
    }
    
    private var text: some View {
        Text(strategy.localizedTitle)
            .foregroundColor(appereance.textColor)
            .font(appereance.textFont)
            .fontWeight(appereance.textWeight)
            .padding(appereance.padding.length * 2)
            .lineLimit(appereance.textLineLimit)
    }
    
    private var overlayCircle: some View {
        Rectangle()
            .foregroundColor(appereance.overlayCircleColor)
            .animation(nil, value: strategy.progressTo)
            .clipShape(Circle().trim(from: strategy.progressStart,
                                   to: trimTo)
                        .stroke(style: appereance.overlayCircleStyle))
            .rotationEffect(appereance.overlayRotation)
    }
    
    private var trimTo: CGFloat {
        let trimTo = strategy.progressTo / (strategy.progressEnd - strategy.progressStart)
        return CGFloat(min(appereance.reverseProgress ? 1 - trimTo : trimTo, 1))
    }
}
