//
//  ChatRequestIdentityActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 4/07/22.
//

import SwiftUI
import Combine

final class ChatIdentityRequestViewModel: BottomActionSheetViewModelProtocol {

    typealias IdentityRequestBottomActionSheet = BottomActionSheet<ChatIdentityRequestActionSheetContent>

    var title: String = L.chatMessageIdentityRequestTitle()
    var primaryAction: IdentityRequestBottomActionSheet.Action = .init(title: L.chatMessageIdentityRequestSend(),
                                                                       isDismissAction: true)
    var secondaryAction: IdentityRequestBottomActionSheet.Action? = .init(title: L.chatMessageIdentityRequestCancel(),
                                                                          isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: IdentityRequestBottomActionSheet.ColorScheme = .main
    var content: ChatIdentityRequestActionSheetContent {
        ChatIdentityRequestActionSheetContent()
    }
}

struct ChatIdentityRequestActionSheetContent: View {
    var body: some View {
        Text(L.chatMessageIdentityRequestSubtitle())
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatRequestIdentityContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
