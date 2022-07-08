//
//  RegisterNameAvatarView+AvatarInput.swift
//  vexl
//
//  Created by Diego Espinoza on 25/02/22.
//

import SwiftUI

extension RegisterNameAvatarView {

    struct AvatarInputView: View {

        var name: String
        var avatar: Data?
        var addAction: () -> Void
        var deleteAction: () -> Void

        var body: some View {
            RegistrationHeaderCardView(title: L.registerNameAvatarImageTitle(),
                                       subtitle: L.registerNameAvatarImageSubtitle(),
                                       iconName: R.image.onboarding.eye.name,
                                       header: greetingView,
                                       content: addAvatarButton)
                .padding(.all, Appearance.GridGuide.point)
        }

        var greetingView: some View {
            HStack {
                Image(R.image.onboarding.wave.name)

                Text(L.registerNameAvatarImageHeader(name))
                    .foregroundColor(Appearance.Colors.purple4)
                    .textStyle(.h3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }

        var addAvatarButton: some View {
            RegisterNameAvatarView.AddAvatarView(image: avatar,
                                                 addAction: {
                addAction()
            },
                                                 deleteAction: {
                deleteAction()
            })
        }
    }

    private struct AddAvatarView: View {

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
                                .clipShape(Circle())
                                .frame(size: defaultImageSize)
                        } else {
                            Image(R.image.onboarding.addAvatar.name)
                        }
                    }

                    if image != nil {
                        Button {
                            deleteAction()
                        } label: {
                            Image(R.image.onboarding.trash.name)
                        }
                    }
                }
            }
            .padding(.top, Appearance.GridGuide.mediumPadding2)
            .padding(.bottom, Appearance.GridGuide.largePadding2)
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG || DEVEL

struct RegisterNameAvatarInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView.AvatarInputView(name: "Name",
                                               avatar: R.image.onboarding.testAvatar()?.jpegData(compressionQuality: 1),
                                               addAction: {},
                                               deleteAction: {})

        RegisterNameAvatarView.AvatarInputView(name: "Name",
                                               avatar: nil,
                                               addAction: {},
                                               deleteAction: {})
    }
}

#endif
