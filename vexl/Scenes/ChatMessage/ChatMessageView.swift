//
//  ChatMessageView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct ChatMessageView: View {

    @ObservedObject var viewModel: ChatMessageViewModel

    var body: some View {
        ZStack {
            content
                .zIndex(0)

            modalView
                .zIndex(1)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var content: some View {
        VStack(spacing: .zero) {
            ChatMessageHeaderView(username: viewModel.username,
                                  avatar: viewModel.avatar,
                                  offerType: viewModel.offerType,
                                  closeAction: {
                viewModel.action.send(.dismissTap)
            })

            HLine(color: Appearance.Colors.whiteOpaque, height: 1)
                .padding(.top, Appearance.GridGuide.smallPadding)

            ChatMessageActionView { chatAction in
                withAnimation {
                    viewModel.action.send(.chatActionTap(action: chatAction))
                }
            }

            ChatMessageConversationView(messages: viewModel.messages)
                .frame(maxHeight: .infinity)

            ChatMessageInputView(text: $viewModel.currentMessage,
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
            if viewModel.modal != .none {
                dimmingView
                    .zIndex(2)
            }

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
                case .none:
                    EmptyView()
                }
            }
            .zIndex(3)
            .transition(.move(edge: .bottom))
        }
    }

    private var dimmingView: some View {
        Color.black
            .opacity(viewModel.modal == .none ? 0 : 0.8)
            .animation(.easeInOut(duration: 0.25), value: viewModel.modal)
            .onTapGesture {
                withAnimation {
                    viewModel.action.send(.dismissModal)
                }
            }
    }

    private var offerView: some View {
        ChatMessageOfferView {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        }
    }

    private var commonFriendView: some View {
        ChatMessageCommonFriendsView(friends: viewModel.friends) {
            withAnimation {
                viewModel.action.send(.dismissModal)
            }
        }
    }

    private var deleteView: some View {
        ChatMessageDeleteConfirmationView(style: .regular,
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
        ChatMessageDeleteConfirmationView(style: .confirmation,
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
        ChatMessageBlockConfirmationView(style: .regular,
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
        ChatMessageBlockConfirmationView(style: .confirmation,
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
}

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
