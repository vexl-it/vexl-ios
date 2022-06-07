//
//  ChatContactBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatBubbleView: View {

    let text: String
    let style: Style

    private var backgroundColor: Color {
        switch style {
        case .contact:
            return Appearance.Colors.gray1
        case .user:
            return Appearance.Colors.yellow100
        }
    }

    private var textColor: Color {
        switch style {
        case .contact:
            return Appearance.Colors.whiteText
        case .user:
            return Appearance.Colors.primaryText
        }
    }

    var body: some View {
        Text(text)
            .textStyle(.paragraphSmallMedium)
            .foregroundColor(textColor)
            .padding(Appearance.GridGuide.smallPadding)
            .background(backgroundColor)
            .cornerRadius(Appearance.GridGuide.requestCorner)
            .frame(maxWidth: .infinity, alignment: style == .contact ? .leading : .trailing)
            .frame(minHeight: 40)
            .padding(style == .contact ? .trailing : .leading, Appearance.GridGuide.mediumPadding2)
    }
}

extension ChatBubbleView {
    enum Style {
        case contact
        case user
    }
}

struct ChatMessageBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatBubbleView(text: "qwertyyutwrewerwer qwer qwertyyutwrewerwer qwertyyutwrewerwer qwertyyutwrewerwer ", style: .contact)
            ChatBubbleView(text: "qwererwer qwertyyrewewer qwetyyutwrewerwer qwertyyutwrewerwer qwer erew12312erwer ", style: .user)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}
