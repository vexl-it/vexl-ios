//
//  ChatConversationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatConversationView: View {

    @ObservedObject var viewModel: ChatConversationViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(viewModel.messages) { section in

                    // TODO: - add date display when its clear how it will be grouped

                    ForEach(section.messages) { message in
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
                                    viewModel.action.send(.imageTapped(sectionId: section.id.uuidString, messageId: message.id.uuidString))
                                }
                        case .requestIdentityReveal:
                            ChatRevealIdentityView(image: nil,
                                                   isRequest: true,
                                                   revealAction: nil)
                        case .receiveIdentityReveal:
                            ChatRevealIdentityView(image: nil,
                                                   isRequest: false,
                                                   revealAction: {
                                viewModel.action.send(.revealTapped)
                            })
                        case .rejectIdentityReveal:
                            ChatRevealIdentityResponseView(username: viewModel.username,
                                                           avatarImage: viewModel.avatarImage,
                                                           rejectImage: viewModel.rejectImage,
                                                           isAccepted: false)
                        case .approveIdentityReveal:
                            ChatRevealIdentityResponseView(username: viewModel.username,
                                                           avatarImage: viewModel.avatarImage,
                                                           rejectImage: viewModel.rejectImage,
                                                           isAccepted: true)
                        case .noContent:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(.top, Appearance.GridGuide.padding)
        }
        .padding([.horizontal, .top], Appearance.GridGuide.point)
    }
}

#if DEBUG || DEVEL

struct ChatConversationViewPreview: PreviewProvider {
    static var previews: some View {
        ChatConversationView(viewModel: .init(inboxKeys: ECCKeys(),
                                              receiverPublicKey: "12345"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif