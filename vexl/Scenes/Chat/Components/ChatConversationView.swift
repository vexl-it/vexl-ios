//
//  ChatConversationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatConversationView: View {

    let messages: [ChatMessageGroup]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(messages) { messageGroup in
                    ChatDateView(date: messageGroup.date, isInitial: false)

                    ForEach(messageGroup.messages) { message in
                        if let imageData = message.image, let image = UIImage(data: imageData) {
                            ChatImageBubbleView(image: image, style: message.isContact ? .contact : .user)
                        } else {
                            ChatTextBubbleView(text: message.text, style: message.isContact ? .contact : .user)
                        }
                    }
                }
            }
            .padding(.top, Appearance.GridGuide.padding)
        }
        .padding([.horizontal, .top], Appearance.GridGuide.point)
    }
}
