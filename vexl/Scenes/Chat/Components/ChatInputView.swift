//
//  ChatInputView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatInputView: View {

    @Binding var text: String
    let sendAction: () -> Void
    let cameraAction: () -> Void

    @State private var textHeight: CGFloat = .zero

    var body: some View {
        HStack {
            Button {
                cameraAction()
            } label: {
                Image(R.image.chat.camera.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)
                    .padding(Appearance.GridGuide.point)
                    .background(Appearance.Colors.gray1)
                    .clipShape(Circle())
            }

            HStack {
                ExpandingTextView(
                    placeholder: L.chatMessageInputPlaceholder(),
                    text: $text,
                    height: textHeight,
                    textColor: Appearance.Colors.whiteText
                )
                    .padding(.top, Appearance.GridGuide.tinyPadding)

                Button {
                    sendAction()
                } label: {
                    Image(R.image.chat.sendMessage.name)
                        .resizable()
                        .frame(size: Appearance.GridGuide.iconSize)
                        .padding(Appearance.GridGuide.tinyPadding)
                        .background(Appearance.Colors.yellow100)
                        .clipShape(Circle())
                }
            }
            .padding()
            .frame(height: Appearance.GridGuide.chatTextFieldHeight)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.chatTextFieldHeight * 0.5)
            .readSize { size in
                textHeight = size.height
            }
        }
    }
}

struct ChatMessageInputViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatInputView(text: .constant("Hello there"),
                                 sendAction: {},
                                 cameraAction: {})
                .background(Color.black)
                .previewDevice("iPhone 11")

            ChatInputView(text: .constant(""),
                                 sendAction: {},
                                 cameraAction: {})
                .background(Color.black)
                .previewDevice("iPhone 11")
        }
    }
}
