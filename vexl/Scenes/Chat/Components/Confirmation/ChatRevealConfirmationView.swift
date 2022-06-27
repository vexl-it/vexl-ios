//
//  ChatRevealConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatRevealConfirmationView: View {

    let isRequest: Bool
    let mainAction: () -> Void
    let dismiss: () -> Void

    private var title: String {
        isRequest ? L.chatMessageIdentityRequestTitle() : L.chatMessageIdentityConfirmationTitle()
    }

    private var subtitle: String {
        isRequest ? L.chatMessageIdentityRequestSubtitle() : L.chatMessageIdentityConfirmationSubtitle()
    }

    private var actionTitle: String {
        isRequest ? L.chatMessageIdentityRequestSend() : L.chatMessageIdentityConfirmationYes()
    }

    private var dismissTitle: String {
        isRequest ? L.chatMessageIdentityRequestCancel() : L.chatMessageIdentityConfirmationCancel()
    }

    var body: some View {
        ChatConfirmationView(title: title,
                             subtitle: subtitle,
                             actionTitle: actionTitle,
                             dismissTitle: dismissTitle,
                             primaryColor: .main,
                             secondaryColor: .secondary,
                             mainAction: mainAction,
                             dismiss: dismiss)
    }
}
