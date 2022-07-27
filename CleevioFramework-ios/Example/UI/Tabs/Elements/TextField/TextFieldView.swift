//
//  TextFieldView.swift
//  CleevioUIExample
//
//  Created by Diego on 17/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct TextFieldContainerView: View, Content {
    
    var name: String { "TextField View" }
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        CLTextField(placeholder: "This is a placeholder", text: .constant(""), type: .default)
            .padding(.horizontal, 16)
    }
    
}

