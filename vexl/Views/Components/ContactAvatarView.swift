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
        let avatarImage: Image

        if let image = image {
            avatarImage = Image(uiImage: image)
        } else {
            avatarImage = Image(R.image.marketplace.defaultAvatar.name)
        }

        return avatarImage
            .resizable()
            .frame(size: size)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}
