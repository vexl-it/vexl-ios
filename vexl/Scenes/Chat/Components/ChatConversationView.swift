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
                    ForEach(messageGroup.messages) { message in
                        switch message.type {
                        case .start:
                            ChatStartTextView()
                                .padding(.bottom, Appearance.GridGuide.padding)
                        case .text:
                            ChatTextBubbleView(text: message.text ?? "",
                                               style: message.isContact ? .contact : .user)
                        case .image:
                            ChatImageBubbleView(image: message.previewImage,
                                                text: message.text,
                                                style: message.isContact ? .contact : .user)
                                .onTapGesture {
                                    imageAction(messageGroup.id.uuidString, message.id.uuidString)
                                }
                        case .sendReveal:
                            ChatRevealIdentityView(image: nil,
                                                   isRequest: true,
                                                   revealAction: nil)
                        case .receiveReveal:
                            ChatRevealIdentityView(image: nil,
                                                   isRequest: false,
                                                   revealAction: {
                                revealAction()
                            })
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
