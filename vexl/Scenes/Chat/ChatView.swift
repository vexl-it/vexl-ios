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

            ChatActionView { chatAction in
                withAnimation {
                    viewModel.action.send(.chatActionTap(action: chatAction))
                }
            }

            ChatConversationView(messages: viewModel.messages,
                                 revealAction: {
                withAnimation {
                    viewModel.action.send(.revealResponseTap)
                }
            })
                .frame(maxHeight: .infinity)
                .padding(.bottom, Appearance.GridGuide.point)

            ChatInputView(text: $viewModel.currentMessage,
                          sendAction: {
                viewModel.action.send(.messageSend)
            },
                          cameraAction: {
                viewModel.action.send(.cameraTap)
            })
                .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
        }
    }

    private var modalView: some View {
        Group {
            if viewModel.isModalPresented {
                dimmingView
            }

            modalSheet
        }
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
        Group {
            switch viewModel.modal {
            case .offer:
                offerView
            case .friends:
                commonFriendView
            case .delete:
                deleteView
            case .deleteConfirmation:
                deleteConfirmationView
            case .block:
                blockView
            case .blockConfirmation:
                blockConfirmationView
            case .identityRevealRequest:
                identityRevealRequestView
            case .identityRevealConfirmation:
                identityRevealConfirmationView
            case .none:
                EmptyView()
            }
        }
        .transition(.move(edge: .bottom))
    }

    private var offerView: some View {
        ChatOfferView {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        }
    }

    private var commonFriendView: some View {
        ChatCommonFriendsView(friends: viewModel.friends) {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        }
    }

    private var deleteView: some View {
        ChatDeleteConfirmationView(style: .regular,
                                   mainAction: {
            withAnimation {
                viewModel.action.send(.deleteTap)
            }
        },
                                          dismiss: {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        })
    }

    private var deleteConfirmationView: some View {
        ChatDeleteConfirmationView(style: .confirmation,
                                   mainAction: {
            withAnimation {
                viewModel.action.send(.deleteConfirmedTap)
            }
        },
                                          dismiss: {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        })
    }

    private var blockView: some View {
        ChatBlockConfirmationView(style: .regular,
                                  mainAction: {
            withAnimation {
                viewModel.action.send(.blockTap)
            }
        },
                                         dismiss: {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        })
    }

    private var blockConfirmationView: some View {
        ChatBlockConfirmationView(style: .confirmation,
                                  mainAction: {
            withAnimation {
                viewModel.action.send(.blockConfirmedTap)
            }
        },
                                         dismiss: {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        })
    }

    private var identityRevealRequestView: some View {
        ChatRevealConfirmationView(isRequest: true ,
                                   mainAction: {
            withAnimation {
                viewModel.action.send(.revealRequestConfirmationTap)
            }
        },
                                   dismiss: {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        })
    }

    private var identityRevealConfirmationView: some View {
        ChatRevealConfirmationView(isRequest: false ,
                                   mainAction: {
            withAnimation {
                viewModel.action.send(.revealResponseConfirmationTap)
            }
        },
                                   dismiss: {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        })
    }
}

#if DEBUG || DEVEL

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
