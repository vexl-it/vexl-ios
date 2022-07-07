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

    var title: String = L.chatMessageDeleteTitle()
    var primaryAction: DeleteBottomActionSheet.Action = .init(title: L.chatMessageDeleteAction(), isDismissAction: true)
    var secondaryAction: DeleteBottomActionSheet.Action? = .init(title: L.chatMessageDeleteBack(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: DeleteBottomActionSheet.ColorScheme = .main
    var content: ChatDeleteActionSheetContent {
        ChatDeleteActionSheetContent()
    }
}

struct ChatDeleteActionSheetContent: View {
    var body: some View {
        Text(L.chatMessageDeleteDescription())
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatDeleteActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
