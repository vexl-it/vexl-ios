//
//  SolidButtonContainer.swift
//  CleevioUIExample
//
//  Created by Diego on 17/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct SolidButtonContainerView: View, Content {
    
    @State var isLoading: Bool = false
    
    var name: String { "Solid Button" }
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        SolidButton(Text("Button Example"), isLoading: $isLoading) {
            isLoading.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.isLoading.toggle()
            })
        }
        .padding(.horizontal, 16)
    }
}
