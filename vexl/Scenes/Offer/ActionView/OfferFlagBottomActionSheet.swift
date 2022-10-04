//
//  OfferFlagBottomActionSheet.swift
//  vexl
//
//  Created by Adam Salih on 04.10.2022.
//

import SwiftUI
import Combine

final class OfferFlagBottomActionSheetViewModel: BottomActionSheetViewModelProtocol {
    typealias OfferFlagBottomActionSheet = BottomActionSheet<OfferFlagBottomActionSheetContent, EmptyView>

    var primaryAction: OfferFlagBottomActionSheet.Action = .init(
        title: L.reportOfferModalButtonYes(),
        isDismissAction: true
    )

    var secondaryAction: OfferFlagBottomActionSheet.Action? = .init(
        title: L.reportOfferModalButtonNo(),
        isDismissAction: true
    )
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: OfferFlagBottomActionSheet.ColorScheme = .main

    var title: String {
        L.reportOfferModalTitle()
    }

    var content: OfferFlagBottomActionSheetContent {
        OfferFlagBottomActionSheetContent()
    }

    var imageName: String? = R.image.marketplace.flagOfferModalImage.name
}

struct OfferFlagBottomActionSheetContent: View {
    var body: some View {
        Text(L.reportOfferModalSubtitle())
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(.paragraph)
            .foregroundColor(Appearance.Colors.gray3)
            .padding(.vertical, Appearance.GridGuide.padding)
    }
}

struct OfferFlagActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        BottomActionSheetView(viewModel: OfferFlagBottomActionSheetViewModel())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .previewDevice("iPhone 14 Pro Max")
    }
}
