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
            ExpandableCoinVariationHeaderView(currencySymbol: viewModel.currencySymbol,
                                              amount: viewModel.amount)

            content
                .background(Color.black.edgesIgnoringSafeArea(.bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Appearance.Colors.green1
                        .edgesIgnoringSafeArea(.all))
    }

    private var content: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            BuySellSegmentView()
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            BuySellFilterView()

            ScrollView {
                ForEach(viewModel.feedItems) { item in
                    BuySellFeedView(title: item.title,
                                    isRequested: item.isRequested,
                                    location: item.location)
                        .padding(.horizontal, Appearance.GridGuide.point)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .cornerRadius(Appearance.GridGuide.padding)
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
