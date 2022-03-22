//
//  LoadingIndicatorView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/03/22.
//

import SwiftUI

struct LoadingIndicatorView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Appearance.Colors.purple4))
        }
        .frame(width: Appearance.GridGuide.largePadding2 * 2, height: Appearance.GridGuide.largePadding2 * 2)
        .background(Appearance.Colors.gray4)
        .cornerRadius(Appearance.GridGuide.point)
    }
}
