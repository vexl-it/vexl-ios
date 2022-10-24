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
        ZStack {
            Appearance.Colors.yellow100
                .ignoresSafeArea()

            Image(R.image.splash.sunglasses.name)
                .resizable()
                .scaledToFit()
                .frame(height: viewModel.animationState.height)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.4, blendDuration: 0), value: viewModel.animationState
                )

            ZStack(alignment: .bottom) {
                if viewModel.showReencryptionProgress {
                    Color.black
                        .opacity(Appearance.dimmingViewOpacity)
                        .transition(.opacity)
                        .ignoresSafeArea()

                    OfferSettingsProgressView(currentValue: viewModel.currentEncryptedItemCount,
                                              maxValue: viewModel.maxEncryptedItemCount)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct SplashScreenViewPreview: PreviewProvider {
    static var previews: some View {
        SplashScreenView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}
