//
//  RegisterNameAvatarView+AvatarInput.swift
//  vexl
//
//  Created by Diego Espinoza on 25/02/22.
//

import SwiftUI

struct RegisterAvatarInputView: View {

    var name: String
    @Binding var avatar: Data?
    var addAction: () -> Void
    var deleteAction: () -> Void

    var title: String {
        "\(L.registerNameAvatarImageHeader(name))\n\(L.registerNameAvatarImageTitle())"
    }

    var body: some View {
        RegistrationCardView(title: title,
                             subtitle: .regular(L.registerNameAvatarImageSubtitle()),
                             subtitlePositionIsBottom: false,
                             iconName: R.image.onboarding.eye.name,
                             bottomPadding: Appearance.GridGuide.padding,
                             content: {
            VStack {
                Spacer()
                addAvatarButton
                Spacer()
            }
        })
            .padding([.horizontal, .bottom], Appearance.GridGuide.point)
    }

    var addAvatarButton: some View {
        RegisterAvatarAddImageView(image: $avatar,
                                   addAction: {
            addAction()
        },
                                   deleteAction: {
            deleteAction()
        })
    }
}

private struct RegisterAvatarAddImageView: View {

    @Binding var image: Data?
    var addAction: () -> Void
    var deleteAction: () -> Void

    private let defaultImageSize: CGSize = Appearance.GridGuide.avatarPickerSize

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(data: image, placeholder: R.image.onboarding.addAvatar.name)
                .resizable()
                .scaledToFill()
                .frame(size: defaultImageSize)
                .clipped()
                .cornerRadius(Appearance.GridGuide.requestAvatarCorner)
                .onTapGesture {
                    addAction()
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
        .padding(.top, Appearance.GridGuide.mediumPadding1)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG || DEVEL

struct RegisterNameAvatarInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterAvatarInputView(name: "Name",
                                avatar: .constant(R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1)),
                                addAction: {},
                                deleteAction: {})
            .background(Color.black)

        RegisterAvatarInputView(name: "Name",
                                avatar: .constant(nil),
                                addAction: {},
                                deleteAction: {})
            .background(Color.black)
    }
}

#endif
