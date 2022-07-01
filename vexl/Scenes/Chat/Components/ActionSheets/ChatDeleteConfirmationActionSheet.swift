//
//  ChatDeleteConfirmationActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

class ChatDeleteConfirmationViewModel: BottomActionSheetViewModelProtocol {

    var title: String = L.chatMessageOffer()
    var primaryAction: BottomActionSheet<ChatDeleteConfirmationActionSheetContent>.Action = .init(title: L.buttonGotIt(), isDismissAction: true)
    var secondaryAction: BottomActionSheet<ChatDeleteConfirmationActionSheetContent>.Action?
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<ChatDeleteConfirmationActionSheetContent>.ColorScheme = .main
    var content: ChatDeleteConfirmationActionSheetContent {
        ChatDeleteConfirmationActionSheetContent(data: OfferDetailViewData(offer: .stub,
                                                                           isRequested: false),
                                                 dismiss: {})
    }
}

struct ChatDeleteConfirmationActionSheetContent: View {

    let data: OfferDetailViewData
    let dismiss: () -> Void

    var body: some View {
        OfferInformationDetailView(data: data,
                                   useInnerPadding: true,
                                   showBackground: false)
            .background(Appearance.Colors.gray6)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .padding(.bottom, Appearance.GridGuide.point)
    }
}

#if DEBUG || DEVEL

struct ChatDeleteConfirmationActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteConfirmationActionSheetContent(data: .stub, dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
