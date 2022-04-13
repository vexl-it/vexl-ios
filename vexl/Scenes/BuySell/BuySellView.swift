//
//  BuySellView.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import SwiftUI
import Cleevio
import Combine

struct BuySellView: View {

    @ObservedObject var viewModel: BuySellViewModel

    var body: some View {
        VStack {
            CoinVariationHeaderView(currencySymbol: viewModel.currencySymbol,
                                    amount: viewModel.amount)

            VStack(spacing: Appearance.GridGuide.mediumPadding2) {
                BuySellSegmentView()
                    .padding(.top, Appearance.GridGuide.mediumPadding2)

                BuySellFilterView()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.black)
            .cornerRadius(Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Appearance.Colors.green1.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL
struct BuySellViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
#endif
