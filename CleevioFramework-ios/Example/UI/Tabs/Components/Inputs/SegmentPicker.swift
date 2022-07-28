//
//  SegmentPicker.swift
//  CleevioUIExample
//
//  Created by Diego on 18/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct SegmentPickerContainerView: View, Content {
    
    private enum Example: Identifiable {
        
        var id: String { text }
        
        case one
        case two
        case three
        
        var text: String {
            switch self {
            case .one: return "One"
            case .two: return "Two"
            case .three: return "Three"
            }
        }
    }
    
    @State private var selectedItem = Example.two
    
    var name: String { "Segment Picker" }
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        CLSegmentedPicker(items: [Example.one, .two, .three], selection: $selectedItem) { item in
            Text(item.text)
        }
        .padding(.horizontal, 16)
    }
    
}
