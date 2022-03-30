//
//  LoadingContainerView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/03/22.
//

import SwiftUI
import Cleevio

struct LoadingContainerView<Content: View>: View {
    var loading: Bool
    var content: () -> Content

    var body: some View {
        ZStack {
            if loading {
                LoadingIndicatorView()
                    .zIndex(2)
            }

            content()
                .zIndex(1)
        }
    }
}
