//
//  PullUpContainerView.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 2/13/21.
//

import SwiftUI
import Cleevio

public struct PullUpContainerView: View {
    let positions = [
        PullUpFlexiblePosition(screenPercentage: 0.9, type: .max),
        PullUpFlexiblePosition(screenPercentage: 0.6, type: .middle),
        PullUpFlexiblePosition(screenPercentage: 0.4, type: .middle),
        PullUpFlexiblePosition(screenPercentage: 0.2, type: .min)
    ]

    public var body: some View {
        ZStack {
            MapView()
                .edgesIgnoringSafeArea(.all)

            PullUpFlexibleScrollableView(supportedPositions: positions, initialPosition: positions[1]) {
                ScrollableContentView()
            }
//            PullUpScrollableView(initialPosition: .middle) {
//                ScrollableContentView()
//            }
        }
        // better to ignore navBar so height doesn't interfere in scrollable view height
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    public init() {}
}

struct PullUpContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PullUpContainerView()
    }
}
