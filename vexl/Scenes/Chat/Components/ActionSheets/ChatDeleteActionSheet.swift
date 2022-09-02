//
//  ChatDeleteActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

final class ChatDeleteSheetViewModel: BottomActionSheetViewModelProtocol {

    typealias DeleteBottomActionSheet = BottomActionSheet<ChatDeleteActionSheetContent, LottieView>

    var primaryAction: DeleteBottomActionSheet.Action = .init(title: L.chatMessageDeleteAction(), isDismissAction: true)
    var secondaryAction: DeleteBottomActionSheet.Action? = .init(title: L.chatMessageDeleteBack(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: DeleteBottomActionSheet.ColorScheme = .main
    var content: ChatDeleteActionSheetContent {
        ChatDeleteActionSheetContent(viewModel: self)
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
    @ObservedObject var viewModel: ChatDeleteSheetViewModel

    var body: some View {
        Text(viewModel.description)
            .textStyle(.paragraph)
            .frame(maxWidth: .infinity)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
            .id(viewModel.description)
    }
}

#if DEBUG || DEVEL

struct ChatDeleteActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteActionSheetContent(viewModel: .init(isConfirmation: false))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
