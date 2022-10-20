//
//  ChatInputView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatInputView: View {

    @Binding var text: String
    @Binding var isLoading: Bool
    let image: Data?
    let sendAction: () -> Void
    let cameraAction: () -> Void
    let deleteImageAction: () -> Void

    var body: some View {
        HStack {

            // TODO: - Activate back when images are supported crossplatform

            //            Button {
            //                cameraAction()
            //            } label: {
            //                Image(R.image.chat.camera.name)
            //                    .resizable()
            //                    .frame(size: Appearance.GridGuide.iconSize)
            //                    .padding(Appearance.GridGuide.point)
            //                    .background(Appearance.Colors.gray1)
            //                    .clipShape(Circle())
            //            }

            VStack(alignment: .leading) {
                if let image = image {
                    SelectedImageView(image: image, deleteAction: {
                        deleteImageAction()
                    })
                    .padding(.top, Appearance.GridGuide.point)
                }

                ExpandingTextView(
                    placeholder: L.chatMessageInputPlaceholder(),
                    text: $text,
                    isFirstResponder: true,
                    minHeight: Appearance.GridGuide.chatTextFieldHeight,
                    textColor: Appearance.Colors.whiteText,
                    enableMaxCharacters: false
                )
                .disabled(isLoading)
            }

            Button {
                if !isLoading {
                    sendAction()
                }
            } label: {
                if !isLoading {
                    Image(R.image.chat.sendMessage.name)
                        .resizable()
                        .frame(size: Appearance.GridGuide.iconSize)
                        .padding(Appearance.GridGuide.tinyPadding)
                        .background(Appearance.Colors.yellow100)
                        .clipShape(Circle())
                } else {
                    LoadingDotsView(dotCount: 3, dotDiameter: 4, color: .black)
                        .frame(size: Appearance.GridGuide.iconSize)
                        .padding(Appearance.GridGuide.tinyPadding)
                        .background(Appearance.Colors.yellow100)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, Appearance.GridGuide.tinyPadding)
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.chatTextFieldHeight * 0.5)
    }
}

extension ChatInputView {
    struct SelectedImageView: View {
        let image: Data
        let deleteAction: () -> Void

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Image(data: image, placeholder: "")
                    .resizable()
                    .frame(size: Appearance.GridGuide.chatInputImageSize)
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
                          isLoading: .constant(false),
                          image: nil,
                          sendAction: {},
                          cameraAction: {},
                          deleteImageAction: {})
            .background(Color.black)
            .previewDevice("iPhone 11")

            ChatInputView(text: .constant(""),
                          isLoading: .constant(false),
                          image: nil,
                          sendAction: {},
                          cameraAction: {},
                          deleteImageAction: {})
            .background(Color.black)
            .previewDevice("iPhone 11")

            ChatInputView(text: .constant("Hello there"),
                          isLoading: .constant(false),
                          image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!,
                          sendAction: {},
                          cameraAction: {},
                          deleteImageAction: {})
            .background(Color.black)
            .previewDevice("iPhone 11")
        }
    }
}

#endif
