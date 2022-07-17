//
//  EditProfileAvatarView.swift
//  vexl
//
//  Created by Diego Espinoza on 17/07/22.
//

import SwiftUI

struct EditProfileAvatarView: View {

    @ObservedObject var viewModel: EditProfileAvatarViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.padding) {
            HeaderTitleView(title: L.userProfileEditAvatarTitle(),
                            showsSeparator: false,
                            dismissAction: {
                viewModel.action.send(.dismissTap)
            })

            selectAvatar
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if viewModel.isAvatarUpdated {
                
            } else {
                LargeSolidButton(title: L.continue(),
                                 font: Appearance.TextStyle.paragraphBold.font.asFont,
                                 style: .main,
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: {
                    
                })
            }
        }
        .padding(Appearance.GridGuide.padding)
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
    }

    private var selectAvatar: some View {
        ZStack(alignment: .topTrailing) {
            Image(data: viewModel.avatar, placeholder: R.image.onboarding.addAvatar.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: Appearance.GridGuide.largeIconSize)
                .cornerRadius(Appearance.GridGuide.padding)
                .padding(Appearance.GridGuide.point)

            Group {
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .frame(size: Appearance.GridGuide.smallIconSize)
            }
            .frame(size: Appearance.GridGuide.iconSize, alignment: .center)
            .background(Appearance.Colors.yellow100)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .onTapGesture {
            viewModel.action.send(.selectAvatar)
        }
    }
}

#if DEBUG || DEVEL

struct EditProfileAvatarViewPreview: PreviewProvider {

    static var viewModel: EditProfileAvatarViewModel {
        let viewModel = EditProfileAvatarViewModel()
        return viewModel
    }

    static var previews: some View {
        EditProfileAvatarView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
