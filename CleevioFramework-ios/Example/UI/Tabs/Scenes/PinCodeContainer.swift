//
//  PinCodeView.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI
import Cleevio

struct PinCodeSceneContainerView: View, Content {
    
    var name: String { "Pin Code" }
    
    var view: AnyView { AnyView(self) }
    
    var body: some View {
        PinCodeOptionsView(viewModel: PinCodeOptionsView.PinCodeOptionsViewModel())
    }
    
}
