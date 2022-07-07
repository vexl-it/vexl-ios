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
        ZStack {
            content
                .zIndex(0)

            modalView
                .zIndex(1)
        }
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

            ChatActionView(isUserRevealed: viewModel.isUserRevealed) { chatAction in
                withAnimation {
                    viewModel.action.send(.chatActionTap(action: chatAction))
                }
            }

            ChatConversationView(messages: viewModel.messages,
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

    @ViewBuilder private var modalView: some View {
        if viewModel.isModalPresented {
            dimmingView
        }

        modalSheet
    }

    private var dimmingView: some View {
        Color.black
            .opacity(Appearance.dimmingViewOpacity)
            .animation(.easeInOut(duration: 0.25), value: viewModel.modal)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                withAnimation {
                    viewModel.action.send(.dismissModal)
                }
            }
            .edgesIgnoringSafeArea(.all)
    }

    private var modalSheet: some View {
        ChatModalContainerView(modal: viewModel.modal,
                               offerDetailViewData: viewModel.offerViewData,
                               commonFriends: viewModel.friends,
                               action: { userAction in
            viewModel.action.send(userAction)
        })
        .transition(.move(edge: .bottom))
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
