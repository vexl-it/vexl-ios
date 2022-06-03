//
//  ChatMessageView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

typealias ChatMessageGroup = ChatMessageView.MessageGroup

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
                                  avatar: nil,
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

            switch viewModel.modal {
            case .offer:
                offerView
            case .none:
                EmptyView()
            }
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
        .zIndex(3)
        .transition(.move(edge: .bottom))
    }
}

extension ChatMessageView {

    struct MessageGroup: Identifiable, Hashable {
        let id = UUID()
        let date: Date
        var messages: [Message]

        // swiftlint: disable nesting
        struct Message: Identifiable, Hashable {
            let id = UUID()
            let text: String
            let isContact: Bool
        }

        mutating func addMessage(_ message: Message) {
            self.messages.append(message)
        }

        static var stub: [MessageGroup] {
            [
                .init(date: Date(), messages: [
                    .init(text: "Hello there", isContact: true),
                    .init(text: "General Kenobi", isContact: false)
                ]),
                .init(date: Date(), messages: [
                    .init(text: "Haha you are a bold one", isContact: false)
                ])
            ]
        }
    }
}

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
