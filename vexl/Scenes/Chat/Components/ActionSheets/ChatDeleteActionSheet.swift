//
//  ChatDeleteActionSheet.swift
//  vexl
//
//  Created by Diego Espinoza on 30/06/22.
//

import SwiftUI
import Combine

class ChatDeleteViewModel: BottomActionSheetViewModelProtocol {

    var title: String = L.chatMessageOffer()
    var primaryAction: BottomActionSheet<ChatDeleteActionSheetContent>.Action = .init(title: L.buttonGotIt(), isDismissAction: true)
    var secondaryAction: BottomActionSheet<ChatDeleteActionSheetContent>.Action?
    var dismissPublisher: PassthroughSubject<Void, Never> = .init()
    var colorScheme: BottomActionSheet<ChatDeleteActionSheetContent>.ColorScheme = .main
    var content: ChatDeleteActionSheetContent {
        ChatDeleteActionSheetContent(data: OfferDetailViewData(offer: .stub,
                                                               isRequested: false),
                                     dismiss: {})
    }
}

struct ChatDeleteActionSheetContent: View {

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

struct ChatDeleteActionSheetContentPreview: PreviewProvider {
    static var previews: some View {
        ChatDeleteActionSheetContent(data: .stub, dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
