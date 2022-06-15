//
//  ChatRevealConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 15/06/22.
//

import SwiftUI

struct ChatRevealConfirmationView: View {

    let mainAction: () -> Void
    let dismiss: () -> Void

    private var title: String {
        L.chatMessageDeleteTitle()
    }

    private var subtitle: String {
        L.chatMessageDeleteDescription()
    }

    var body: some View {
        ChatConfirmationView(title: L.chatMessageIdentityConfirmationTitle(),
                             subtitle: L.chatMessageIdentityConfirmationSubtitle(),
                             actionTitle: L.chatMessageIdentityConfirmationYes(),
                             dismissTitle: L.chatMessageIdentityConfirmationCancel(),
                             primaryColor: .main,
                             secondaryColor: .secondary,
                             mainAction: mainAction,
                             dismiss: dismiss)
    }
}
