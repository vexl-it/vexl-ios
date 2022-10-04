//
//  OfferFlagConfirmationActionSheet.swift
//  vexl
//
//  Created by Adam Salih on 04.10.2022.
//

import Foundation
//
//  OfferFlagBottomActionSheet.swift
//  vexl
//
//  Created by Adam Salih on 04.10.2022.
//

import SwiftUI
import Combine

final class OfferFlagConfirmationActionSheetViewModel: BottomActionSheetViewModelProtocol {
    typealias OfferFlagConfirmationActionSheet = BottomActionSheet<OfferFlagConfirmationActionSheetContent, EmptyView>

    var primaryAction: OfferFlagConfirmationActionSheet.Action = .init(
        title: L.reportOfferConfirmationModalButton(),
        isDismissAction: true
    )

    var secondaryAction: OfferFlagConfirmationActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: OfferFlagConfirmationActionSheet.ColorScheme = .main

    var title: String {
        L.reportOfferConfirmationModalTitle()
    }

    var content: OfferFlagConfirmationActionSheetContent {
        OfferFlagConfirmationActionSheetContent()
    }

    var imageName: String? = R.image.marketplace.flagOfferModalImageFinished.name
}

struct OfferFlagConfirmationActionSheetContent: View {
    var body: some View {
        Text(L.reportOfferConfirmationModalSubtitle())
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

struct OfferFlagConfirmationActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        BottomActionSheetView(viewModel: OfferFlagConfirmationActionSheetViewModel())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 14 Pro Max")
    }
}
