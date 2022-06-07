//
//  ChatBlockConfirmationView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatBlockConfirmationView: View {

    enum Style {
        case regular
        case confirmation
    }

    let style: Style
    let mainAction: () -> Void
    let dismiss: () -> Void

    private var title: String {
        style == .regular ? L.chatMessageBlockTitle() : L.chatMessageBlockConfirmTitle()
    }

    private var subtitle: String {
        style == .regular ? L.chatMessageBlockDescription() : L.chatMessageBlockConfirmDescription()
    }

    var body: some View {
        ChatConfirmationView(title: title,
                                    subtitle: subtitle,
                                    actionTitle: L.chatMessageBlockAction(),
                                    dismissTitle: L.chatMessageBlockBack(),
                                    primaryColor: .red,
                                    secondaryColor: .redSecondary,
                                    mainAction: mainAction,
                                    dismiss: dismiss)
    }
}
