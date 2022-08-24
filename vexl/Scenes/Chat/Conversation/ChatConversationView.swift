//
//  ChatConversationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatConversationView: View {

    @ObservedObject var viewModel: ChatConversationViewModel
    @State private var firstScrollFinished = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(viewModel.messages) { section in
                        // TODO: - add date display when its clear how it will be grouped

                        ForEach(section.messages) { message in
                            Group {
                                switch message.type {
                                case .start:
                                    ChatStartTextView()
                                        .padding(.bottom, Appearance.GridGuide.padding)
                                case .text:
                                    ChatTextBubbleView(text: message.text ?? "",
                                                       style: message.isContact ? .contact : .user)
                                case .image:
                                    ChatImageBubbleView(image: message.imageView,
                                                        text: message.text,
                                                        style: message.isContact ? .contact : .user)
                                        .onTapGesture {
                                            viewModel.action.send(.imageTapped(image: message.image))
                                        }
                                case .requestIdentityReveal:
                                    ChatRevealIdentityView(image: viewModel.avatar,
                                                           isRequest: true)
                                case .receiveIdentityReveal:
                                    ChatRevealIdentityView(image: nil,
                                                           isRequest: false)
                                case .rejectIdentityReveal:
                                    ChatRevealIdentityResponseView(username: viewModel.username,
                                                                   avatarImage: viewModel.avatarImage,
                                                                   rejectImage: viewModel.rejectImage,
                                                                   isAccepted: false,
                                                                   isRecevinng: !message.isContact)
                                case .approveIdentityReveal:
                                    ChatRevealIdentityResponseView(username: viewModel.username,
                                                                   avatarImage: viewModel.avatarImage,
                                                                   rejectImage: viewModel.rejectImage,
                                                                   isAccepted: true,
                                                                   isRecevinng: !message.isContact)
                                case .noContent:
                                    EmptyView()
                                }
                            }
                            .id(message.id)
                        }
                    }
                }
            }
            .padding(.top, Appearance.GridGuide.padding)
            .onReceive(viewModel.$lastMessageID) { newMessageID in
                withAnimation(firstScrollFinished ? .default : .none) {
                    proxy.scrollTo(newMessageID)
                    if !firstScrollFinished {
                        firstScrollFinished = true
                    }
                }
            }
            .onReceive(viewModel.$forceScrollToBottom) { forceScroll in
                if forceScroll {
                    proxy.scrollTo(viewModel.lastMessageID)
                }
            }
        }
        .padding([.horizontal, .top], Appearance.GridGuide.point)
    }
}

#if DEBUG || DEVEL

struct ChatConversationViewPreview: PreviewProvider {
    static var previews: some View {
        ChatConversationView(viewModel: .init(chat: .stub))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
