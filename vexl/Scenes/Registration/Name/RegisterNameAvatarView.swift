//
//  RegisterNameAvatarView.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

struct RegisterNameAvatarView: View {

    @ObservedObject var viewModel: RegisterNameAvatarViewModel

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .phoneVerified:
                PhoneVerified()
            case .usernameInput:
                NameInputView(username: $viewModel.username)

                Spacer()

                actionButton {
                    viewModel.send(action: .setUsername)
                }
                .transaction { $0.disablesAnimations = true }
            case .avatarInput:
                AvatarInputView(name: viewModel.username,
                                avatar: viewModel.avatar,
                                addAction: {
                    viewModel.send(action: .addAvatar)
                },
                                deleteAction: {
                    viewModel.send(action: .deleteAvatar)
                })

                Spacer()

                actionButton {
                    viewModel.send(action: .createUser)
                }
                .transaction { $0.disablesAnimations = true }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .actionSheet(isPresented: $viewModel.showImagePickerActionSheet, content: {
            ActionSheet(title: Text(L.registerNameAvatarImagePicker()),
                        message: nil,
                        buttons: [
                            .default(Text(L.registerNameAvatarCamera())) {
                                viewModel.showImagePicker = true
                                viewModel.imageSource = .camera
                            },
                            .default(Text(L.registerNameAvatarPhotoAlbum())) {
                                viewModel.showImagePicker = true
                                viewModel.imageSource = .photoAlbum
                            },
                            .cancel()
                        ])
        })
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(sourceType: viewModel.imageSource == .photoAlbum ? .photoLibrary : .camera,
                        selectedImage: $viewModel.avatar)
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentState)
    }

    @ViewBuilder private func actionButton(with action: @escaping () -> Void) -> some View {
        LargeSolidButton(title: L.continue(),
                         font: Appearance.TextStyle.h3.font.asFont,
                         style: .custom(color: .welcome),
                         isFullWidth: true,
                         isEnabled: $viewModel.isActionEnabled,
                         action: {
            action()
        })
            .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

struct RegisterNameAvatarViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView(viewModel: .init())
    }
}
