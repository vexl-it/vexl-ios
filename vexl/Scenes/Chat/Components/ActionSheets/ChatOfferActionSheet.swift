//
//  ChatOfferBottomActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

final class ChatOfferSheetViewModel: BottomActionSheetViewModelProtocol {

    typealias OfferBottomActionSheet = BottomActionSheet<ChatOfferActionSheetContent>

    var title: String = L.chatMessageOffer()
    var primaryAction: OfferBottomActionSheet.Action = .init(title: L.buttonGotIt(), isDismissAction: true)
    var secondaryAction: OfferBottomActionSheet.Action?
    var actionPublisher: PassthroughSubject<BottomActionSheetActionType, Never> = .init()
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: OfferBottomActionSheet.ColorScheme = .main
    var content: ChatOfferActionSheetContent {
        ChatOfferActionSheetContent(data: OfferDetailViewData(offer: self.offer,
                                                              isRequested: false),
                                    dismiss: {})
    }

    let offer: Offer

    init(offer: Offer) {
        self.offer = offer
    }
}

struct ChatOfferActionSheetContent: View {

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

struct ChatOfferActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatOfferActionSheetContent(data: .stub, dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
