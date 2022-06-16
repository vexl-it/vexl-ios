//
//  ChatInputView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatInputView: View {

    @Binding var text: String
    let image: UIImage?
    let sendAction: () -> Void
    let cameraAction: () -> Void
    let deleteImageAction: () -> Void

    private var inputHeight: CGFloat {
        if image == nil {
            return Appearance.GridGuide.chatTextFieldHeight
        } else {
            return Appearance.GridGuide.chatTextFieldHeight + Appearance.GridGuide.chatImageSize.height + Appearance.GridGuide.mediumPadding1
        }
    }

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
                VStack(alignment: .leading) {
                    if let image = image {
                        SelectedImageView(image: image,
                                          deleteAction: {
                            deleteImageAction()
                        })
                            .padding(.top, Appearance.GridGuide.point)
                    }

                    ExpandingTextView(
                        placeholder: L.chatMessageInputPlaceholder(),
                        text: $text,
                        height: Appearance.GridGuide.chatTextFieldHeight,
                        textColor: Appearance.Colors.whiteText
                    )
                        .padding(.top, Appearance.GridGuide.tinyPadding)
                }

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
            .frame(height: inputHeight)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.chatTextFieldHeight * 0.5)
        }
    }
}

extension ChatInputView {

    struct SelectedImageView: View {

        let image: UIImage
        let deleteAction: () -> Void

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .frame(size: Appearance.GridGuide.chatImageSize)
                    .cornerRadius(Appearance.GridGuide.containerCorner)

                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Appearance.Colors.gray2)
                }
            }
        }
    }
}

#if DEBUG || DEVEL

struct ChatMessageInputViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatInputView(text: .constant("Hello there"),
                          image: nil,
                          sendAction: {},
                          cameraAction: {},
                          deleteImageAction: {})
                .background(Color.black)
                .previewDevice("iPhone 11")

            ChatInputView(text: .constant(""),
                          image: nil,
                          sendAction: {},
                          cameraAction: {},
                          deleteImageAction: {})
                .background(Color.black)
                .previewDevice("iPhone 11")
            
            ChatInputView(text: .constant("Hello there"),
                          image: R.image.onboarding.testAvatar()!,
                          sendAction: {},
                          cameraAction: {},
                          deleteImageAction: {})
                .background(Color.black)
                .previewDevice("iPhone 11")
        }
    }
}

#endif
