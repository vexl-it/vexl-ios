//
//  RegisterNameAvatarView+AvatarInput.swift
//  vexl
//
//  Created by Diego Espinoza on 25/02/22.
//

import SwiftUI

struct RegisterAvatarInputView: View {

    var name: String
    var avatar: Data?
    var addAction: () -> Void
    var deleteAction: () -> Void

    var title: String {
        "\(L.registerNameAvatarImageHeader(name))\n\(L.registerNameAvatarImageTitle())"
    }

    var body: some View {
        RegistrationCardView(title: title,
                             subtitle: L.registerNameAvatarImageSubtitle(),
                             subtitlePositionIsBottom: false,
                             iconName: R.image.onboarding.eye.name,
                             content: {
            addAvatarButton
                .frame(maxHeight: .infinity)
        })
            .padding(.all, Appearance.GridGuide.point)
    }

    var addAvatarButton: some View {
        RegisterAvatarAddImageView(image: avatar,
                                   addAction: {
            addAction()
        },
                                   deleteAction: {
            deleteAction()
        })
    }
}

private struct RegisterAvatarAddImageView: View {

    var image: Data?
    var addAction: () -> Void
    var deleteAction: () -> Void

    private let defaultImageSize: CGSize = Appearance.GridGuide.avatarSize

    var body: some View {
        VStack(alignment: .center) {
            ZStack(alignment: .topTrailing) {
                Button {
                    addAction()
                } label: {
                    if let image = image {
                        Image(data: image, placeholder: "")
                            .resizable()
                            .scaledToFill()
                            .frame(size: defaultImageSize)
                            .clipped()
                            .cornerRadius(Appearance.GridGuide.requestAvatarCorner)
                    } else {
                        Image(R.image.onboarding.addAvatar.name)
                    }
                }

                if image != nil {
                    Button {
                        deleteAction()
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(Appearance.Colors.primaryText)
                            .padding(Appearance.GridGuide.point)
                            .background(Appearance.Colors.yellow100)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.top, Appearance.GridGuide.mediumPadding2)
        .padding(.bottom, Appearance.GridGuide.largePadding2)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG || DEVEL

struct RegisterNameAvatarInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterAvatarInputView(name: "Name",
                                avatar: R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1),
                                addAction: {},
                                deleteAction: {})
            .background(Color.black)

        RegisterAvatarInputView(name: "Name",
                                avatar: nil,
                                addAction: {},
                                deleteAction: {})
            .background(Color.black)
    }
}

#endif
