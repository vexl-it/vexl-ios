//
//  ContactAvatarView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct ContactAvatarView: View {

    let image: UIImage?
    let size: CGSize

    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .frame(size: size)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        } else {
            Image(R.image.marketplace.defaultAvatar.name)
                .resizable()
                .frame(size: size)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}
