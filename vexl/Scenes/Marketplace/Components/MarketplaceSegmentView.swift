//
//  BuySellView+Segment.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import Cleevio
import SwiftUI

struct MarketplaceSegmentView: View {

    private let selectorHeight: CGFloat = 3
    private let lineWidth: CGFloat = 2

    @Binding var selectedOption: OfferType
    @State private var viewWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            HStack {
                Button {
                    selectedOption = .buy
                } label: {
                    Text(L.marketplaceBuy())
                        .textStyle(.largeTitle)
                        .foregroundColor(selectedOption == .buy ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)

                Button {
                    selectedOption = .sell
                } label: {
                    Text(L.marketplaceSell())
                        .textStyle(.largeTitle)
                        .foregroundColor(selectedOption == .sell ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)
            }

            selectorView
        }
        .readSize { size in
            viewWidth = size.width
        }
    }

    @ViewBuilder var selectorView: some View {
        ZStack(alignment: .leading) {
            HLine()
                .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: [8]))
                .foregroundColor(Appearance.Colors.gray1)

            Color.white
                .frame(width: viewWidth * 0.45, height: selectorHeight, alignment: .leading)
                .offset(x: selectedOption == .buy ? viewWidth * 0.05 : viewWidth * 0.5)
                .animation(.easeIn(duration: 0.15),
                           value: selectedOption)
        }.frame(height: selectorHeight, alignment: .bottom)
    }
}

#if DEBUG || DEVEL
struct MarketplaceSegmentViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceSegmentView(selectedOption: .constant(.buy))
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
