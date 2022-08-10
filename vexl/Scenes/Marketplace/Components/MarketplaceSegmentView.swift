//
//  BuySellView+Segment.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import Cleevio
import SwiftUI

struct MarketplaceSegmentView: View {

    private let selectorHeight: CGFloat = 2

    @Binding var selectedOption: OfferType
    @State private var viewWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding1) {
            HStack {
                Button {
                    selectedOption = .buy
                } label: {
                    Text(L.marketplaceBuy())
                        .textStyle(.h1)
                        .foregroundColor(selectedOption == .buy ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.horizontal, Appearance.GridGuide.padding)
                }
                .frame(maxWidth: .infinity)

                Button {
                    selectedOption = .sell
                } label: {
                    Text(L.marketplaceSell())
                        .textStyle(.h1)
                        .foregroundColor(selectedOption == .sell ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.horizontal, Appearance.GridGuide.padding)
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
            HLine(color: Appearance.Colors.gray1,
                  height: 2)
                .padding(.horizontal, viewWidth * 0.02)

            Appearance.Colors.yellow100
                .frame(width: viewWidth * 0.48, height: selectorHeight, alignment: .leading)
                .offset(x: selectedOption == .buy ? viewWidth * 0.02 : viewWidth * 0.5)
                .animation(.easeIn(duration: 0.15),
                           value: selectedOption)
        }
        .frame(height: selectorHeight, alignment: .bottom)
    }
}

#if DEBUG || DEVEL
struct MarketplaceSegmentViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceSegmentView(selectedOption: .constant(.buy))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
