//
//  LoadingView.swift
//  CleevioUIExample
//
//  Created by Diego on 17/01/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine
import Cleevio

struct LoadingContainerView: View, Content {
    
    var name: String { "Loading View" }
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        LoadingView(circleColor: Color(.systemBlue))
    }
    
}
