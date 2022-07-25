//
//  ReportIssueActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 24/07/22.
//

import SwiftUI
import Combine

final class ReportIssueSheetViewModel: BottomActionSheetViewModelProtocol {

    typealias IdentityBottomActionSheet = BottomActionSheet<ReportIssueActionSheetContent>

    var primaryAction: IdentityBottomActionSheet.Action = .init(title: L.gotIt(), isDismissAction: true)
    var secondaryAction: IdentityBottomActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: IdentityBottomActionSheet.ColorScheme = .main

    var title: String {
        L.userProfileReportErrorTitle()
    }

    var content: ReportIssueActionSheetContent {
        ReportIssueActionSheetContent()
    }
}

struct ReportIssueActionSheetContent: View {

    var body: some View {
        VStack {
            Text(L.userProfileReportErrorSubtitle())
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray3)
                .padding(.vertical, Appearance.GridGuide.padding)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text("@")
                    .textStyle(.titleSmallBold)
                    .foregroundColor(Appearance.Colors.gray3)
                    .padding(Appearance.GridGuide.smallPadding)
                    .background(Appearance.Colors.gray5)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)

                Text(verbatim: Constants.supportEmail)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.primaryText)
            }
            .padding([.horizontal, .bottom], Appearance.GridGuide.point)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG || DEVEL

struct ReportIssueActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ReportIssueActionSheetContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 11")
    }
}

#endif
