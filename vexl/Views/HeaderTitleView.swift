//
//  OfferHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import SwiftUI

struct HeaderTitleView: View {

    let title: String
    let showSeparator: Bool
    let dismissAction: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(title)
                    .textStyle(.h2)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                        .frame(size: Appearance.GridGuide.baseButtonSize)
                        .background(Appearance.Colors.gray1)
                        .cornerRadius(Appearance.GridGuide.point)
                }
            }
            .padding(.bottom, Appearance.GridGuide.point)

            if showSeparator {
                HLine(color: Appearance.Colors.whiteOpaque,
                      height: 1)
            }
        }
    }
}

#if DEVEL || DEBUG

struct OfferHeaderViewPreview: PreviewProvider {
    static var previews: some View {
        HeaderTitleView(title: L.offerSellTitle(),
                        showSeparator: true,
                        dismissAction: {})
            .frame(maxHeight: .infinity)
            .previewDevice("iPhone 11")
            .background(Color.black)

        HeaderTitleView(title: L.offerBuyTitle(),
                        showSeparator: true,
                        dismissAction: {})
            .frame(maxHeight: .infinity)
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}

#endif
