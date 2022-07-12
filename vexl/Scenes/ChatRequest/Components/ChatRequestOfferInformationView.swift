//
//  ChatRequestOfferInformationView.swift
//  vexl
//
//  Created by Diego Espinoza on 27/05/22.
//

import SwiftUI

struct ChatRequestOfferInformationView: View {

    let data: OfferDetailViewData

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {

            Text(L.chatRequestMyOffer())
                .textStyle(.descriptionSemiBold)
                .foregroundColor(Appearance.Colors.gray3)
                .padding([.horizontal, .top], Appearance.GridGuide.padding)

            OfferInformationDetailView(data: data,
                                       useInnerPadding: false,
                                       showBackground: false)
                .padding(Appearance.GridGuide.padding)
        }
    }
}
