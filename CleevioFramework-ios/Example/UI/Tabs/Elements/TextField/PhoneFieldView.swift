//
//  PhoneFieldView.swift
//  CleevioUIExample
//
//  Created by Diego on 25/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct PhoneFieldContainerView: View, Content {
    
    var name: String { "PhoneField" }
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        CLPhoneNumberField(placeholder: "Phone number goes here", text: .constant(""))
            .padding(.horizontal, 16)
    }
}
