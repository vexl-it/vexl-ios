//
//  PullUpView.swift
//  CleevioDemo
//
//  Created by Diego on 6/01/22.
//

import SwiftUI
import Cleevio

struct PullUpSceneContainerView: View, Content {

    var name: String { "Pull Up" }
    var view: AnyView { AnyView(self) }

    var body: some View {
        PullUpContainerView()
    }

}
