//
//  ChatOfferBottomActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

class ChatOfferViewModel: BottomActionSheetViewModelProtocol {

    var title: String = L.chatMessageOffer()
    var primaryAction: BottomActionSheet<ChatOfferActionSheetContent>.Action = .init(title: L.buttonGotIt(), isDismissAction: true)
    var secondaryAction: BottomActionSheet<ChatOfferActionSheetContent>.Action?
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<ChatOfferActionSheetContent>.ColorScheme = .main
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
