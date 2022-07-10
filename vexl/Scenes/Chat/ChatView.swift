//
//  ChatView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct ChatView: View {

    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        content
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
                selectedImage: $viewModel.selectedImage
            )
            .background(Color.black.ignoresSafeArea())
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var content: some View {
        VStack(spacing: .zero) {
            ChatHeaderView(username: viewModel.username,
                           offerLabel: viewModel.offerLabel,
                           avatar: viewModel.avatar,
                           offerType: viewModel.offerType,
                           closeAction: {
                viewModel.action.send(.dismissTap)
            })

            HLine(color: Appearance.Colors.whiteOpaque,
                  height: 1)
                .padding(.top, Appearance.GridGuide.smallPadding)

            ChatActionView(viewModel: viewModel.chatActionViewModel)

            ChatConversationView(username: viewModel.username,
                                 avatar: viewModel.avatar,
                                 messages: viewModel.messages,
                                 revealAction: {
                withAnimation {
                    viewModel.action.send(.revealResponseTap)
                }
            },
                                 imageAction: { groupId, messageId in
                viewModel.action.send(.expandImageTap(groupId: groupId,
                                                      messageId: messageId))
            })
                .frame(maxHeight: .infinity)
                .padding(.bottom, Appearance.GridGuide.point)

            ChatInputView(text: $viewModel.currentMessage,
                          image: viewModel.selectedImageData,
                          sendAction: {
                viewModel.action.send(.messageSend)
            },
                          cameraAction: {
                viewModel.action.send(.cameraTap)
            },
                          deleteImageAction: {
                viewModel.action.send(.deleteImageTap)
            })
                .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
        }
    }
}

#if DEBUG || DEVEL

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: .init(inboxKeys: ECCKeys(), receiverPublicKey: "234", offerType: .buy))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
