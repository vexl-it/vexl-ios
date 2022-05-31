//
//  BuySellView.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import SwiftUI
import Cleevio
import Combine

struct MarketplaceView: View {
    @ObservedObject var viewModel: MarketplaceViewModel
    @State private var bitcoinSize: CGSize = .zero
    @State private var stickHeaderIsVisible = false

    var body: some View {
        StickyBitcoinView(
            bitcoinViewModel: viewModel.bitcoinViewModel,
            content: { marketPlaceContent },
            stickyHeader: { marketPlaceHeader }
        )
        .animation(.easeInOut, value: viewModel.selectedOption)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var marketPlaceContent: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding1) {
            marketPlaceHeader

            ForEach(viewModel.marketplaceFeedItems) { item in
                MarketplaceFeedView(data: item,
                                    displayFooter: false,
                                    detailAction: { id in
                    viewModel.action.send(.offerDetailTapped(id: id))
                },
                                    requestAction: { id in
                    viewModel.action.send(.requestOfferTapped(id: id))
                })
                .padding(.horizontal, Appearance.GridGuide.point)
            }
        }
        .animation(.easeInOut, value: viewModel.marketplaceFeedItems)
    }

    private var marketPlaceHeader: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            MarketplaceSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            filter
        }
    }

    private var filter: some View {
        switch viewModel.selectedOption {
        case .buy:
            return MarketplaceFilterView(
                items: viewModel.buyFilters,
                actionTitle: L.marketplaceSellOffer(),
                mainAction: {
                    viewModel.action.send(.showBuyOffer)
                })
        case .sell:
            return MarketplaceFilterView(
                items: viewModel.sellFilters,
                actionTitle: L.marketplaceSellOffer(),
                mainAction: {
                    viewModel.action.send(.showSellOffer)
                })
        }
    }
}

#if DEBUG || DEVEL
struct BuySellViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceView(
            viewModel: MarketplaceViewModel(
                bitcoinViewModel: .init()
            )
        )
        .previewDevice("iPhone 11")
    }
}
#endif
