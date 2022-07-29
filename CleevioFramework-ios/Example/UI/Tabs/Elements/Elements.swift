//
//  Elements.swift
//  CleevioUIExample
//
//  Created by Diego on 17/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Cleevio
import Combine

struct Element: Section {
    let name = "Elements"
    let icon = "1.square.fill"
    
    var content: [Content] {
        [
            LoadingContainerView(),
            TextFieldContainerView(),
            PhoneFieldContainerView()
        ]
    }
}
