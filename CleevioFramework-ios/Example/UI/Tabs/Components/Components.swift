//
//  Components.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI
import Cleevio
import Combine

struct Component: Section {
    let name = "Components"
    let icon = "2.square.fill"
    
    var content: [Content] {
        [
            SolidButtonContainerView(),
            InputTextFieldContainerView(),
            SegmentPickerContainerView(),
            StepperContainerView()
        ]
    }
}
