//
//  ContactAvatarView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct ContactAvatarView: View {

    let image: Data?
    let size: CGSize

    var body: some View {
        let avatarImage: Image

        if let image = image {
            avatarImage = Image(data: image, placeholder: "")
        } else {
            avatarImage = Image(R.image.marketplace.defaultAvatar.name)
        }

        return avatarImage
            .resizable()
            .scaledToFill()
            .frame(size: size)
            .clipped()
            .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}
