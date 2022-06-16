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

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(messages) { messageGroup in
                    ChatDateView(date: messageGroup.date, isInitial: false)

                    ForEach(messageGroup.messages) { message in
                        switch message.category {
                        case let .text(text):
                            ChatTextBubbleView(text: text,
                                               style: message.isContact ? .contact : .user)
                        case let .image(image, text):
                            if let data = image, let uiImage = UIImage(data: data) {
                                ChatImageBubbleView(image: uiImage,
                                                    text: text,
                                                    style: message.isContact ? .contact : .user)
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
