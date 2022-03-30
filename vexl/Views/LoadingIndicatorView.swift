//
//  LoadingIndicatorView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/03/22.
//

import SwiftUI
import Cleevio

struct LoadingIndicatorView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.25)
                .edgesIgnoringSafeArea(.all)

            VStack {
                LoadingView(circleColor: Color.black)
            }
            .frame(width: Appearance.GridGuide.largePadding2 * 2, height: Appearance.GridGuide.largePadding2 * 2)
            .background(Color.white)
            .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
