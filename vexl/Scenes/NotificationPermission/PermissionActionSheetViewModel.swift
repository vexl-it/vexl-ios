//
//  PermissionActionSheetViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.09.2022.
//

import SwiftUI
import Combine

final class PermissionActionSheetViewModel: BottomActionSheetViewModelProtocol {
    typealias PermissionBottomActionSheet = BottomActionSheet<PermissionActionSheetContent, EmptyView>

    var primaryAction: PermissionBottomActionSheet.Action = .init(
        title: L.notificationsPermissionDialogAllow(),
        isDismissAction: true
    )

    var secondaryAction: PermissionBottomActionSheet.Action? = .init(
        title: L.notificationsPermissionDialogDontAllow(),
        isDismissAction: true
    )
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: PermissionBottomActionSheet.ColorScheme = .main

    var title: String {
        L.notificationsPermissionRejectTitle()
    }

    var content: PermissionActionSheetContent {
        PermissionActionSheetContent()
    }
}

struct PermissionActionSheetContent: View {
    var body: some View {
        Text(L.notificationsPermissionDialogTitle())
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

struct PermissionActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        PermissionActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 11")
    }
}
