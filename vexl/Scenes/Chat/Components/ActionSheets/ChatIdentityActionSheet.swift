//
//  ChatIdentityActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 9/07/22.
//

import SwiftUI
import Combine

final class ChatIdentitySheetViewModel: BottomActionSheetViewModelProtocol {

    typealias IdentityBottomActionSheet = BottomActionSheet<ChatIdentityActionSheetContent, EmptyView>

    var primaryAction: IdentityBottomActionSheet.Action
    var secondaryAction: IdentityBottomActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: IdentityBottomActionSheet.ColorScheme = .main

    var title: String {
        isResponse ? L.chatMessageIdentityConfirmationTitle() : L.chatMessageIdentityRequestTitle()
    }

    var subtitle: String {
        isResponse ? L.chatMessageIdentityConfirmationSubtitle() : L.chatMessageIdentityRequestSubtitle()
    }

    var content: ChatIdentityActionSheetContent? {
        ChatIdentityActionSheetContent(subtitle: subtitle)
    }

    let isResponse: Bool

    init(isResponse: Bool) {
        self.isResponse = isResponse
        self.primaryAction = .init(title: isResponse ? L.chatMessageIdentityConfirmationYes() : L.chatMessageIdentityRequestSend(),
                                   isDismissAction: true)
        self.secondaryAction = .init(title: isResponse ? L.chatMessageIdentityConfirmationCancel() : L.chatMessageIdentityRequestCancel(),
                                     isDismissAction: true)
    }
}

struct ChatIdentityActionSheetContent: View {

    let subtitle: String

    var body: some View {
        Text(subtitle)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatIdentityActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatIdentityActionSheetContent(subtitle: "qwerty")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
