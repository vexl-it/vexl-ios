//
//  ChatConversationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatConversationView: View {

    let messages: [ChatMessageGroup]
    let revealAction: () -> Void
    let imageAction: (String, String) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(messages) { messageGroup in
                    ChatDateView(date: messageGroup.date, isInitial: false)

                    ForEach(messageGroup.messages) { message in
                        switch message.category {
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
