//
//  ChatMessageDeleteConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatMessageDeleteConfirmationView: View {

    enum Style {
        case regular
        case confirmation
    }

    let style: Style
    let mainAction: () -> Void
    let dismiss: () -> Void

    var body: some View {
        ChatMessageConfirmationView(title: style == .regular ? L.chatMessageDeleteTitle() : L.chatMessageDeleteConfirmTitle(),
                                    subtitle: style == .regular ? L.chatMessageDeleteDescription() : L.chatMessageDeleteConfirmDescription(),
                                    actionTitle: L.chatMessageDeleteAction(),
                                    dismissTitle: L.chatMessageDeleteBack(),
                                    primaryColor: .main,
                                    secondaryColor: .secondary,
                                    mainAction: mainAction,
                                    dismiss: dismiss)
    }
}
