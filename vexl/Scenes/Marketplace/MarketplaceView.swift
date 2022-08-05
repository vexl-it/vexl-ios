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
            stickyHeader: { marketPlaceHeader },
            expandedBitcoinGraph: { isExpanded in
                viewModel.action.send(.graphExpanded(isExpanded: isExpanded))
            }
        )
        .coordinateSpace(name: RefreshControlView.coordinateSpace)
        .animation(.easeInOut, value: viewModel.selectedOption)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onAppear(perform: { viewModel.action.send(.fetchNewOffers) })
    }

    private var marketPlaceContent: some View {
        RefreshContainer(topPadding: Appearance.GridGuide.largePadding1,
                         hideRefresh: viewModel.isGraphExpanded,
                         isRefreshing: $viewModel.isRefreshing) {
            VStack(spacing: Appearance.GridGuide.mediumPadding1) {
                marketPlaceHeader

                ForEach(viewModel.marketplaceFeedItems) { item in
                    MarketplaceFeedView(data: item,
                                        displayFooter: false,
                                        detailAction: { _ in
                        viewModel.action.send(.offerDetailTapped(offer: item.offer))
                    },
                                        requestAction: { _ in
                        viewModel.action.send(.requestOfferTapped(offer: item.offer))
                    })
                    .padding(.horizontal, Appearance.GridGuide.point)
                }
            }
            .animation(.easeInOut, value: viewModel.marketplaceFeedItems)
        }
    }

    private var marketPlaceHeader: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            MarketplaceSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            filter
        }
    }

    @ViewBuilder
    private var filter: some View {
        switch viewModel.selectedOption {
        case .buy:
            MarketplaceFilterView(
                items: viewModel.buyFilters,
                hasFilters: viewModel.userSelectedFilters,
                hasOffers: !viewModel.fetchedBuyOffers.isEmpty,
                mainAction: {
                    viewModel.action.send(.showBuyOffer)
                }
            )
            .animation(.easeInOut, value: viewModel.userSelectedFilters)
        case .sell:
            MarketplaceFilterView(
                items: viewModel.sellFilters,
                hasFilters: viewModel.userSelectedFilters,
                hasOffers: !viewModel.fetchedSellOffers.isEmpty,
                mainAction: {
                    viewModel.action.send(.showSellOffer)
                }
            )
            .animation(.easeInOut, value: viewModel.userSelectedFilters)
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
