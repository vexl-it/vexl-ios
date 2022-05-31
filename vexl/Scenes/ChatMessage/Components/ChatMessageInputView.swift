//
//  ChatMessageInputView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatMessageInputView: View {

    @Binding var text: String
    let sendAction: () -> Void
    let cameraAction: () -> Void

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
                PlaceholderTextField(placeholder: L.chatMessageInputPlaceholder(),
                                     textColor: Appearance.Colors.gray4,
                                     text: $text)

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
        }
    }
}

struct ChatMessageInputViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageInputView(text: .constant("Hello there"),
                             sendAction: {},
                             cameraAction: {})
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
