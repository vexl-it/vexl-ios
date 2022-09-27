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

    var primaryAction: PermissionBottomActionSheet.Action

    var secondaryAction: PermissionBottomActionSheet.Action? = .init(
        title: L.notificationsPermissionDialogDontAllow(),
        isDismissAction: true
    )
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: PermissionBottomActionSheet.ColorScheme = .main

    var title: String {
        isDenied ?
        L.notificationsPermissionDisabledTitle() :
        L.notificationsPermissionRejectTitle()
    }

    var content: PermissionActionSheetContent {
        PermissionActionSheetContent(isDenied: isDenied)
    }

    let isDenied: Bool

    init(isDenied: Bool) {
        self.isDenied = isDenied
        let primaryActionTitle = isDenied ? L.notificationsPermissionDisabledButton() : L.notificationsPermissionDialogAllow()

        primaryAction = .init(
            title: primaryActionTitle,
            isDismissAction: true
        )
    }
}

struct PermissionActionSheetContent: View {
    let isDenied: Bool

    private var title: String {
        isDenied ?
        L.notificationsPermissionDisabledSubtitle() :
        L.notificationsPermissionDialogTitle()
    }

    var body: some View {
        Text(title)
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

struct PermissionActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        PermissionActionSheetContent(isDenied: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 11")
    }
}
