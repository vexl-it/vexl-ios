//
//  ChatOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 31/05/22.
//

import SwiftUI
import Cleevio

struct ChatOfferView: View {

    let dismiss: () -> Void

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(L.chatMessageOffer())
                    .textStyle(.h2)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .padding(.horizontal, Appearance.GridGuide.point)

                OfferInformationDetailView(data: .stub,
                                           useInnerPadding: true,
                                           showBackground: false)
                    .background(Appearance.Colors.gray6)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                    .padding(.bottom, Appearance.GridGuide.point)
            }
            .padding(.top, Appearance.GridGuide.mediumPadding1)
            .padding(.horizontal, Appearance.GridGuide.point)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Appearance.Colors.whiteText)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            LargeSolidButton(title: L.buttonGotIt(),
                             font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                dismiss()
            })
        }
        .padding(Appearance.GridGuide.point)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

#if DEBUG || DEVEL

struct ChatOfferViewPreview: PreviewProvider {
    static var previews: some View {
        ChatOfferView(dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}

#endif
