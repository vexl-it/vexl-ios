//
//  ChatMessageOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 31/05/22.
//

import SwiftUI
import Cleevio

struct ChatMessageOfferView: View {

    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {

            Color.black
                .zIndex(0)

            VStack {
                VStack(alignment: .leading) {
                    Text("My Offer")
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

                SolidButton(Text("Got it"),
                            iconImage: nil,
                            isEnabled: .constant(true),
                            isLoading: .constant(false),
                            fullWidth: true,
                            loadingViewScale: 1,
                            font: Appearance.TextStyle.titleSmallSemiBold.font.asFont,
                            colors: .main,
                            dimensions: .largeButton,
                            action: {
                    dismiss()
                })
            }
            .padding(Appearance.GridGuide.point)
            .zIndex(1)
        }
    }
}

struct ChatMessageOfferViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageOfferView(dismiss: { })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .previewDevice("iPhone 11")
    }
}
