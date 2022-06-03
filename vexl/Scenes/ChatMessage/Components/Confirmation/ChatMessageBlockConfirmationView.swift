//
//  ChatMessageBlockConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatMessageBlockConfirmationView: View {

    enum Style {
        case regular
        case confirmation
    }

    let style: Style
    let mainAction: () -> Void
    let dismiss: () -> Void

    var body: some View {
        ChatMessageConfirmationView(title: style == .regular ? L.chatMessageBlockTitle() : L.chatMessageBlockConfirmTitle(),
                                    subtitle: style == .regular ? L.chatMessageBlockDescription() : L.chatMessageBlockConfirmDescription(),
                                    actionTitle: L.chatMessageBlockAction(),
                                    dismissTitle: L.chatMessageBlockBack(),
                                    primaryColor: .red,
                                    secondaryColor: .redSecondary,
                                    mainAction: mainAction,
                                    dismiss: dismiss)
    }
}
