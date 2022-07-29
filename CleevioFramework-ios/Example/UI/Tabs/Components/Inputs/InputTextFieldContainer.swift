//
//  InputTextFieldContainer.swift
//  CleevioUIExample
//
//  Created by Diego on 18/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct InputTextFieldContainerView: View, Content {
    
    @State var text: String = "Hello"
    @State var isActive: Bool = false
    
    var name: String { "InputTextField" }
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        CLInputTextField(viewModel: .init(placeholder: "Placeholder", inputText: $text, isActive: $isActive), textFont: Font.body)
            .padding(.horizontal, 16)
    }
    
}
