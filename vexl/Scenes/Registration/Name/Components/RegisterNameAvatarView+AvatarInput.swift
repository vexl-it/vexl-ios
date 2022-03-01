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
        var avatar: UIImage?
        var addAction: () -> Void
        var deleteAction: () -> Void

        var body: some View {
            RegistrationHeaderCardView(title: L.registerNameAvatarImageTitle(),
                                       subtitle: L.registerNameAvatarImageSubtitle(),
                                       header: greetingView,
                                       content: addAvatarButton)
                .padding(.all, Appearance.GridGuide.point)
        }

        var greetingView: some View {
            Text(L.registerNameAvatarImageHeader(name))
                .foregroundColor(Appearance.Colors.purple4)
                .textStyle(.h2)
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

        var image: UIImage?
        var addAction: () -> Void
        var deleteAction: () -> Void

        private var defaultImageSize: CGSize {
            R.image.onboarding.addAvatar()?.size ?? Appearance.GridGuide.avatarSize
        }

        var body: some View {
            VStack(alignment: .center) {
                ZStack(alignment: .topTrailing) {

                    Button {
                        addAction()
                    } label: {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .frame(size: defaultImageSize)
                                .cornerRadius(defaultImageSize.height * 0.5)
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

struct RegisterNameAvatarInputViewPreview: PreviewProvider {
    static var previews: some View {
        let avatar = UIImage(named: R.image.onboarding.testAvatar.name)
        return RegisterNameAvatarView.AvatarInputView(name: "Name",
                                                      avatar: avatar,
                                                      addAction: {},
                                                      deleteAction: {})
    }
}
