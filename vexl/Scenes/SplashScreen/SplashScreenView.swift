//
//  SplashScreenView.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject var viewModel: SplashScreenViewModel

    let cleevioColor: Color = .init(red: 247 / 255, green: 207 / 255, blue: 88 / 255, opacity: 1)
    let logoSize: CGFloat = 200

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(cleevioColor)
            logo
        }
        .edgesIgnoringSafeArea(.all)
    }

    var logo: some View {
            ZStack {
                ZStack {
                    ZStack {
                        Circle()
                            .frame(width: logoSize * 0.64, height: logoSize * 0.64)
                            .foregroundColor(cleevioColor)

                        Circle()
                            .frame(width: logoSize * 0.37, height: logoSize * 0.37)

                        Rectangle()
                            .frame(width: logoSize * 0.64 * 0.5, height: logoSize * 0.64, alignment: .trailing)
                            .offset(x: logoSize * 0.64 * 0.25, y: 0)
                    }
                    .rotationEffect(.degrees(30))

                    VStack(spacing: 0) {
                        Rectangle()
                            .frame(height: logoSize * 0.64 - logoSize * 0.18)
                            .foregroundColor(.clear)

                        Circle()
                            .frame(width: logoSize * 0.13, height: logoSize * 0.13)
                            .offset(x: (logoSize * 0.13) / 2, y: 0)
                            .foregroundColor(cleevioColor)
                    }
                }
            }
            .frame(width: logoSize, height: logoSize)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.4, style: .continuous))
    }
}

struct SplashScreenViewPreview: PreviewProvider {
    static var previews: some View {
        SplashScreenView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}
