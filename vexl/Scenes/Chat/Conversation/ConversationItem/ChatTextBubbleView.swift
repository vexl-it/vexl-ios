//
//  ChatTextBubbleView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatTextBubbleView: View {

    private let text: String
    private let style: ChatBubbleStyle
    private let urlHandler: (URL) -> Void

    private var attirbutedText: NSAttributedString
    private var textView: Text = Text("")
    private var hasURL: Bool = false
    private var urls: [URL] = []

    @State private var width: CGFloat = .zero

    init(text: String, style: ChatBubbleStyle, urlHandler: @escaping (URL) -> Void) {
        self.text = text
        self.style = style
        self.urlHandler = urlHandler
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let textRange = NSRange(location: 0, length: text.count)
        let matches = detector?.matches(in: text, options: [], range: textRange) ?? []
        let attributedText = NSMutableAttributedString(string: text)
        for match in matches {
            let urlString = attributedText.attributedSubstring(from: match.range).string
            if let url = URL(string: urlString) {
                self.urls.append(url)
                attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single, range: match.range)
            }
        }
        self.attirbutedText = attributedText
    }

    var body: some View {
        ChatBubbleView(style: style) {
            Menu {
                menuItems
            } label: {
                attributed(string: text)
                    .multilineTextAlignment(.leading)
                    .textStyle(.paragraphSmallMedium)
                    .padding(Appearance.GridGuide.smallPadding)
            }
        }
        .padding(style == .contact ? .trailing : .leading, Appearance.GridGuide.mediumPadding2)
    }

    func attributed(string: String) -> Text {
        let textRange = NSRange(location: 0, length: text.count)
        var text = Text("")
        attirbutedText.enumerateAttributes(in: textRange, options: []) { attrs, range, _ in
            let urlString = attirbutedText.attributedSubstring(from: range).string
            var tmpText = Text(urlString)
            if attrs[.underlineStyle] != nil {
                tmpText = tmpText
                    .foregroundColor(.blue)
                    .underline()
            }
            text = text + tmpText // swiftlint:disable:this shorthand_operator
        }
        return text
    }

    @ViewBuilder
    var menuItems: some View {
        Button(L.chatMessageCopyMessage()) {
            UIPasteboard.general.string = text
        }

        ForEach(urls, id: \.self) { url in
            Button {
                UIPasteboard.general.string = url.absoluteString
            } label: {
                Label("\(L.chatMessageCopyLink()) \"\(url.absoluteString)\"", systemImage: "plus.circle")
            }
            if UIApplication.shared.canOpenURL(url) {
                Button {
                    urlHandler(url)
                } label: {
                    Label("\(L.chatMessageOpenLink()) \"\(url.absoluteString)\"", systemImage: "plus.circle")
                }
            }
        }
    }
}

#if DEBUG || DEVEL

struct ChatTextBubbleViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatTextBubbleView(text: "qwerty qwerty qwerty qwerty qwerty qwerty qwerty", style: .contact, urlHandler: { _ in })

            ChatTextBubbleView(text: "qwerty qwerty qwerty qwerty", style: .user, urlHandler: { _ in })
        }
        .frame(maxHeight: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")

        VStack {
            ChatImageBubbleView(image: Image(uiImage: R.image.onboarding.testAvatar()!),
                                text: nil,
                                style: .contact)

            ChatImageBubbleView(image: Image(uiImage: R.image.onboarding.testAvatar()!),
                                text: nil,
                                style: .user)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .previewDevice("iPhone 11")
    }
}

#endif
