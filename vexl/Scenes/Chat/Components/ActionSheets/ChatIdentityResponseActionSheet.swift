//
//  ChatIdentityResponseActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 4/07/22.
//

import SwiftUI
import Combine

final class ChatIdentityResponseViewModel: BottomActionSheetViewModelProtocol {

    typealias IdentityResponseBottomActionSheet = BottomActionSheet<ChatIdentityResponseActionSheetContent>

    var title: String = L.chatMessageIdentityConfirmationTitle()
    var primaryAction: IdentityResponseBottomActionSheet.Action = .init(title: L.chatMessageIdentityConfirmationYes(),
                                                                        isDismissAction: true)
    var secondaryAction: IdentityResponseBottomActionSheet.Action? = .init(title: L.chatMessageIdentityConfirmationCancel(),
                                                                           isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: IdentityResponseBottomActionSheet.ColorScheme = .main
    var content: ChatIdentityResponseActionSheetContent {
        ChatIdentityResponseActionSheetContent()
    }
}

struct ChatIdentityResponseActionSheetContent: View {
    var body: some View {
        Text(L.chatMessageIdentityConfirmationSubtitle())
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatIdentityResponseContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
