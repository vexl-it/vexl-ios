//
//  StepperViewContainer.swift
//  CleevioUIExample
//
//  Created by Diego on 25/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct StepperContainerView: View, Content {
    
    var name: String { "StepperView" }
    var view: AnyView { AnyView(self) }
    
    @State var count = 1
    
    var body: some View {
        CLStepperView(increaseButtonDisabled: false,
                      quantity: $count,
                      backgroundColor: Color(.systemGroupedBackground),
                      isLoading: .constant(false),
                      increaseAction: { count += 1 },
                      decreaseAction: { count -= 1 })
            .frame(size: CGSize(width: 240, height: 64))
    }
    
}
