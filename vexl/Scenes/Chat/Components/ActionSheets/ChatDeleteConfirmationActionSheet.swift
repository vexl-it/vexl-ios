//
//  ChatDeleteConfirmationActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

class ChatDeleteConfirmationViewModel: BottomActionSheetViewModelProtocol {

    var title: String = L.chatMessageDeleteConfirmTitle()
    var primaryAction: BottomActionSheet<ChatDeleteConfirmationActionSheetContent>.Action = .init(title: L.chatMessageDeleteAction(),
                                                                                                  isDismissAction: true)
    var secondaryAction: BottomActionSheet<ChatDeleteConfirmationActionSheetContent>.Action? = .init(title: L.chatMessageDeleteBack(),
                                                                                                     isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<ChatDeleteConfirmationActionSheetContent>.ColorScheme = .main
    var sheetIsVisible: ((Bool) -> Void)?
    var content: ChatDeleteConfirmationActionSheetContent {
        ChatDeleteConfirmationActionSheetContent()
    }
}

struct ChatDeleteConfirmationActionSheetContent: View {
    var body: some View {
        Text(L.chatMessageDeleteConfirmDescription())
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatDeleteConfirmationSheetPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteConfirmationActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
