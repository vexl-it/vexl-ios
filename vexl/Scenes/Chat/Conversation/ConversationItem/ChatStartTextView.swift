//
//  ChatStartTextView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/06/22.
//

import SwiftUI

struct ChatStartTextView: View {
    var body: some View {
        Text(L.chatMessageConversationRequestAccepted())
            .textStyle(.descriptionSemiBold)
            .foregroundColor(Appearance.Colors.gray3)
    }
}

#if DEBUG || DEVEL

struct ChatStartTextViewPreview: PreviewProvider {
    static var previews: some View {
        ChatStartTextView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
