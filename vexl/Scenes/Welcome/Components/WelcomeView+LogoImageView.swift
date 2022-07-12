//
//  LoginLogoView.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import SwiftUI

extension WelcomeView {

    struct LogoImageView: View {
        var body: some View {
            ZStack {
                Image(R.image.logo.logoSize4.name)
                Image(R.image.logo.logoSize3.name)
                Image(R.image.logo.logoSize2.name)
                Image(R.image.logo.logoSize1.name)
            }
        }
    }
}

struct WelcomeLogoViewPreview: PreviewProvider {
    static var previews: some View {
        WelcomeView.LogoImageView()
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
