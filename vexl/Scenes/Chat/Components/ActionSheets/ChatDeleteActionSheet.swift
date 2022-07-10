//
//  ChatDeleteActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

final class ChatDeleteViewModel: BottomActionSheetViewModelProtocol {

    typealias DeleteBottomActionSheet = BottomActionSheet<ChatDeleteActionSheetContent>

    var primaryAction: DeleteBottomActionSheet.Action = .init(title: L.chatMessageDeleteAction(), isDismissAction: true)
    var secondaryAction: DeleteBottomActionSheet.Action? = .init(title: L.chatMessageDeleteBack(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: DeleteBottomActionSheet.ColorScheme = .main
    var content: ChatDeleteActionSheetContent {
        ChatDeleteActionSheetContent(description: description)
    }

    var title: String {
        isConfirmation ? L.chatMessageDeleteConfirmTitle() : L.chatMessageDeleteTitle()
    }

    var description: String {
        isConfirmation ? L.chatMessageDeleteConfirmDescription() : L.chatMessageDeleteDescription()
    }

    let isConfirmation: Bool

    init(isConfirmation: Bool) {
        self.isConfirmation = isConfirmation
    }
}

struct ChatDeleteActionSheetContent: View {

    let description: String

    var body: some View {
        Text(description)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatDeleteActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteActionSheetContent(description: "qwerty")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
