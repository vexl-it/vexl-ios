//
//  OfferHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct OfferHeaderView: View {

    let title: String
    let dismissAction: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text(title)
                    .textStyle(.h2)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                        .padding(Appearance.GridGuide.point)
                        .background(Appearance.Colors.gray1)
                        .cornerRadius(Appearance.GridGuide.point)
                }
                .frame(size: Appearance.GridGuide.baseButtonSize)
                .padding(.top, Appearance.GridGuide.point)
            }
            .padding(.bottom, Appearance.GridGuide.point)

            HLine(color: Appearance.Colors.whiteOpaque,
                  height: 1)
        }
    }
}

#if DEVEL || DEBUG

struct OfferHeaderViewPreview: PreviewProvider {
    static var previews: some View {
        OfferHeaderView(title: L.offerSellTitle(), dismissAction: {})
            .frame(maxHeight: .infinity)
            .previewDevice("iPhone 11")
            .background(Color.black)

        OfferHeaderView(title: L.offerBuyTitle(), dismissAction: {})
            .frame(maxHeight: .infinity)
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}

#endif
