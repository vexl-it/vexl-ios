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

    @Binding var selectedOption: MarketplaceViewModel.Option

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            HStack {
                Button {
                    selectedOption = .buy
                } label: {
                    Text(L.marketplaceBuy())
                        .textStyle(.h1)
                        .foregroundColor(selectedOption == .buy ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)

                Button {
                    selectedOption = .sell
                } label: {
                    Text(L.marketplaceSell())
                        .textStyle(.h1)
                        .foregroundColor(selectedOption == .sell ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)
            }

            selectorView
        }
    }

    @ViewBuilder var selectorView: some View {
        ZStack {
            HLine()
                .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: [8]))
                .foregroundColor(Appearance.Colors.gray1)

            GeometryReader { reader in
                Color.white
                    .frame(width: reader.size.width * 0.45, height: selectorHeight)
                    .offset(x: selectedOption == .buy ? reader.size.width * 0.05 : reader.size.width * 0.5)
                    .animation(.easeIn(duration: 0.15),
                               value: selectedOption)
            }
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
