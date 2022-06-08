//
//  ChatDeleteConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatDeleteConfirmationView: View {

    let style: Style
    let mainAction: () -> Void
    let dismiss: () -> Void

    private var title: String {
        style == .regular ? L.chatMessageDeleteTitle() : L.chatMessageDeleteConfirmTitle()
    }

    private var subtitle: String {
        style == .regular ? L.chatMessageDeleteDescription() : L.chatMessageDeleteConfirmDescription()
    }

    var body: some View {
        ChatConfirmationView(title: title,
                             subtitle: subtitle,
                             actionTitle: L.chatMessageDeleteAction(),
                             dismissTitle: L.chatMessageDeleteBack(),
                             primaryColor: .main,
                             secondaryColor: .secondary,
                             mainAction: mainAction,
                             dismiss: dismiss)
    }
}

extension ChatDeleteConfirmationView {
    enum Style {
        case regular
        case confirmation
    }
}
