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
                                  offerLabel: viewModel.offerLabel,
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
            if viewModel.isModalPresented {
                dimmingView
            }

            switch viewModel.modal {
            case .offer:
                offerView
            case .friends:
                commonFriendView
            case .none:
                EmptyView()
            }
        }
    }

    private var dimmingView: some View {
        Color.black
            .opacity(Appearance.dimmingViewOpacity)
            .animation(.easeInOut(duration: 0.25), value: viewModel.modal)
            .onTapGesture {
                withAnimation {
                    viewModel.action.send(.dismissModal)
                }
            }
    }

    private var offerView: some View {
        ChatMessageOfferView {
            viewModel.action.send(.dismissModal)
        }
        .transition(.move(edge: .bottom))
    }

    private var commonFriendView: some View {
        ChatMessageCommonFriendsView(friends: viewModel.friends) {
            viewModel.action.send(.dismissModal)
        }
        .transition(.move(edge: .bottom))
    }
}

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
