//
//  GroupsLeaveActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 9/08/22.
//

import SwiftUI
import Combine

final class GroupsLeaveSheetViewModel: BottomActionSheetViewModelProtocol {
    typealias LeaveBottomActionSheet = BottomActionSheet<GroupsLeaveActionSheetContent>

    var primaryAction: LeaveBottomActionSheet.Action = .init(title: L.groupsLeaveGroupYes(), isDismissAction: true)
    var secondaryAction: LeaveBottomActionSheet.Action? = .init(title: L.groupsLeaveGroupNo(), isDismissAction: true)
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: LeaveBottomActionSheet.ColorScheme = .red

    var imageName: String? {
        R.image.profile.groupsLeave.name
    }

    var title: String {
        L.groupsLeaveGroupTitle()
    }

    var content: GroupsLeaveActionSheetContent {
        GroupsLeaveActionSheetContent()
    }
}

struct GroupsLeaveActionSheetContent: View {
    var body: some View {
        Text(L.groupsLeaveGroupDescription())
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL

struct GroupsLeaveActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        GroupsLeaveActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 11")
    }
}

#endif
