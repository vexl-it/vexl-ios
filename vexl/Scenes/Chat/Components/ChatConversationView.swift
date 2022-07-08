//
//  ChatConversationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatConversationView: View {

    let messages: [ChatConversationSection]
    let revealAction: () -> Void
    let imageAction: (String, String) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(messages) { messageGroup in

                    // TODO: - add date display when its clear how it will be grouped

                    ForEach(messageGroup.messages) { message in
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
                                    imageAction(messageGroup.id.uuidString, message.id.uuidString)
                                }
                        case .requestIdentityReveal:
                            ChatRevealIdentityView(image: nil,
                                                   isRequest: true,
                                                   revealAction: nil)
                        case .receiveIdentityReveal:
                            ChatRevealIdentityView(image: nil,
                                                   isRequest: false,
                                                   revealAction: {
                                revealAction()
                            })
                        case .rejectIdentityReveal:
                            ChatRevealIdentityResponseView(image: nil,
                                                           isAccepted: false)
                        case .approveIdentityReveal:
                            ChatRevealIdentityResponseView(image: nil,
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
        ChatConversationView(messages: ChatConversationSection.stub,
                             revealAction: {},
                             imageAction: { _, _ in })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
