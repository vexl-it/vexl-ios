//
//  SplashScreenView.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject var viewModel: SplashScreenViewModel

    var body: some View {
        Text("SplashScreen")
    }
}

struct SplashScreenViewPreview: PreviewProvider {
    static var previews: some View {
        SplashScreenView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}
