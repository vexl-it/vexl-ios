//
//  DeleteAccountActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 3/08/22.
//

import SwiftUI
import Combine

final class DeleteAccountSheetViewModel: BottomActionSheetViewModelProtocol {
    typealias DeleteBottomActionSheet = BottomActionSheet<DeleteAccountActionSheetContent, EmptyView>

    var primaryAction: DeleteBottomActionSheet.Action
    var secondaryAction: DeleteBottomActionSheet.Action? = .init(title: L.userProfileDeleteAccountNo(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: DeleteBottomActionSheet.ColorScheme = .red

    var title: String {
        isConfirmation ? L.userProfileDeleteAccountTitleSure() : L.userProfileDeleteAccountTitle()
    }

    var content: DeleteAccountActionSheetContent {
        DeleteAccountActionSheetContent()
    }

    let isConfirmation: Bool

    init(isConfirmation: Bool) {
        self.isConfirmation = isConfirmation
        self.primaryAction = .init(title: isConfirmation ? L.userProfileDeleteAccountYes() : L.userProfileDeleteAccountYesDelete(),
                                   isDismissAction: true)
    }
}

struct DeleteAccountActionSheetContent: View {

    var body: some View {
        Text(L.userProfileDeleteAccountSubtitle())
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct DeleteAccountActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        DeleteAccountActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 11")
    }
}

#endif
