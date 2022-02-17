//
//  LoginLogoView.swift
//  vexl
//
//  Created by Diego Espinoza on 16/02/22.
//

import SwiftUI

struct LoginLogoView: View {
    var body: some View {
        ZStack {
            Image(R.image.logo.logoSize4.name)
            Image(R.image.logo.logoSize3.name)
            Image(R.image.logo.logoSize2.name)
            Image(R.image.logo.logoSize1.name)
        }
    }
}

struct LoginLogoViewPreview: PreviewProvider {
    static var previews: some View {
        LoginLogoView()
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
