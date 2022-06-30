//
//  ChatOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 31/05/22.
//

import SwiftUI
import Cleevio

struct ChatOfferView: View {

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

struct ChatOfferViewPreview: PreviewProvider {
    static var previews: some View {
        ChatOfferView(data: .stub, dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
