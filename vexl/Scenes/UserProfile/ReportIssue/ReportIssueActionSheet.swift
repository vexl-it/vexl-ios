//
//  ReportIssueActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 24/07/22.
//

import SwiftUI
import Combine

final class ReportIssueSheetViewModel: BottomActionSheetViewModelProtocol {

    typealias IdentityBottomActionSheet = BottomActionSheet<ReportIssueActionSheetContent, EmptyView>

    var primaryAction: IdentityBottomActionSheet.Action = .init(title: L.gotIt(), isDismissAction: true)
    var secondaryAction: IdentityBottomActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: IdentityBottomActionSheet.ColorScheme = .main

    var title: String {
        L.userProfileReportIssueTitle()
    }

    var content: ReportIssueActionSheetContent {
        ReportIssueActionSheetContent { [weak self] in
            self?.actionPublisher.send(.contentAction)
        }
    }
}

struct ReportIssueActionSheetContent: View {

    var action: () -> Void

    var body: some View {
        VStack {
            Text(L.userProfileReportIssueSubtitle())
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

                Text(verbatim: L.userProfileReportIssueEmail())
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.primaryText)
            }
            .onTapGesture {
                action()
            }
            .padding([.horizontal, .bottom], Appearance.GridGuide.point)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG || DEVEL

struct ReportIssueActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ReportIssueActionSheetContent {}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 11")
    }
}

#endif
