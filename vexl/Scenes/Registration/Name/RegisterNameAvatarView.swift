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
    }

    @ViewBuilder private func actionButton(with action: @escaping () -> Void) -> some View {
        SolidButton(Text(L.continue()),
                    isEnabled: $viewModel.isActionEnabled,
                    font: Appearance.TextStyle.h3.font.asFont,
                    colors: SolidButtonColor.welcome,
                    dimensions: SolidButtonDimension.largeButton) {
            action()
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

struct RegisterNameAvatarViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView(viewModel: .init())
    }
}
