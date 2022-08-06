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
    private let transition = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .scale).combined(with: .opacity)

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .startRegistration:
                RegisterNameAvatarStartView()
                    .transition(transition)
            case .usernameInput:
                nameInputView
            case .avatarInput:
                avatarInputView
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
        .fullScreenCover(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                sourceType: viewModel.imageSource == .photoAlbum ? .photoLibrary : .camera,
                selectedImage: $viewModel.avatar
            )
            .background(Color.black.ignoresSafeArea())
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentState)
    }

    private var nameInputView: some View {
        Group {
            RegisterNameInputView(username: $viewModel.username)
                .transition(transition)

            Spacer()

            actionButton(title: L.generalSave()) {
                viewModel.send(action: .setUsername)
            }
            .transaction { $0.disablesAnimations = true }
        }
    }

    private var avatarInputView: some View {
        Group {
            RegisterAvatarInputView(name: viewModel.username,
                                    avatar: viewModel.avatar,
                                    addAction: {
                viewModel.send(action: .addAvatar)
            },
                                    deleteAction: {
                viewModel.send(action: .deleteAvatar)
            })
                .transition(transition)

            Spacer()

            actionButton(title: viewModel.avatarButtonTitle) {
                viewModel.send(action: .createUser)
            }
            .transaction { $0.disablesAnimations = true }
        }
    }

    @ViewBuilder private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        LargeSolidButton(title: title,
                         font: Appearance.TextStyle.titleSmallBold.font.asFont,
                         style: .main,
                         isFullWidth: true,
                         isEnabled: $viewModel.isActionEnabled,
                         action: {
            action()
        })
            .padding(.horizontal, Appearance.GridGuide.point)
            .padding(.bottom, Appearance.GridGuide.padding)
    }
}

struct RegisterNameAvatarViewPreview: PreviewProvider {

    static var avatarViewModel: RegisterNameAvatarViewModel {
        let viewModel = RegisterNameAvatarViewModel()
        viewModel.currentState = .avatarInput
        return viewModel
    }

    static var nameViewModel: RegisterNameAvatarViewModel {
        let viewModel = RegisterNameAvatarViewModel()
        viewModel.currentState = .usernameInput
        return viewModel
    }

    static var previews: some View {
        RegisterNameAvatarView(viewModel: .init())
        RegisterNameAvatarView(viewModel: nameViewModel)
        RegisterNameAvatarView(viewModel: avatarViewModel)
    }
}
