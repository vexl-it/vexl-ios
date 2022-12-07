//
//  ChatBlockActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 29/07/22.
//

import SwiftUI
import Combine
import Cleevio

class ChatBlockSheetViewModel: BottomActionSheetViewModelProtocol {

    typealias ChatBlockBottomSheet = BottomActionSheet<ChatBlockActionSheetContent, LottieView>

    var primaryAction: ChatBlockBottomSheet.Action = .init(title: L.chatMessageBlockAction(), isDismissAction: true)
    var secondaryAction: ChatBlockBottomSheet.Action? = .init(title: L.chatMessageBlockBack(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: ChatBlockBottomSheet.ColorScheme = .red
    var imageView: LottieView? {
        isConfirmation
            ? LottieView(animation: .blockUser, playMode: .pause(.end))
            : LottieView(animation: .blockUser, loopMode: .playOnce)
    }
    var content: ChatBlockActionSheetContent? {
        ChatBlockActionSheetContent(description: description)
    }

    var title: String {
        isConfirmation ? L.chatMessageBlockConfirmTitle() : L.chatMessageBlockTitle()
    }

    var description: String {
        isConfirmation ? L.chatMessageBlockConfirmDescription() : L.chatMessageBlockDescription()
    }

    private var isConfirmation: Bool

    init(isConfirmation: Bool) {
        self.isConfirmation = isConfirmation
    }
}

struct ChatBlockActionSheetContent: View {
    let description: String

    var body: some View {
        Text(description)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct ChatBlockActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatBlockActionSheetContent(description: "1234")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
