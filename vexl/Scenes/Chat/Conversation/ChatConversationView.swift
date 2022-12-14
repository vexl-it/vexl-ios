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
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(viewModel.messages) { section in
                        // TODO: - add date display when its clear how it will be grouped
                        ForEach(section.messages) { message in
                            cell(for: message)
                                .id(message.id)
                        }
                    }
                }
            }
            .padding(.top, Appearance.GridGuide.padding)
            .onReceive(viewModel.$lastMessageID, perform: { newMessageID in
                withAnimation {
                    proxy.scrollTo(newMessageID)
                }
            })
        }
        .padding([.horizontal, .top], Appearance.GridGuide.point)
    }

    @ViewBuilder
    func cell(for message: ChatConversationItem) -> some View {
        Group {
            switch message.type {
            case .start:
                ChatStartTextView()
                    .padding(.bottom, Appearance.GridGuide.padding)
            case .text:
                ChatTextBubbleView(text: message.text ?? "",
                                   style: message.isContact ? .contact : .user,
                                   urlHandler: { url in viewModel.action.send(.open(url: url)) })
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
