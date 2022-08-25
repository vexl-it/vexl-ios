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
            isMarketplaceLocked: viewModel.isMarketplaceLocked,
            content: { marketPlaceContent },
            stickyHeader: {
                marketPlaceHeader.padding(.bottom, Appearance.GridGuide.point)
            },
            expandedBitcoinGraph: { isExpanded in
                viewModel.action.send(.graphExpanded(isExpanded: isExpanded))
            },
            lockedSellAction: {
                viewModel.action.send(.showSellOffer)
            },
            lockedBuyAction: {
                viewModel.action.send(.showBuyOffer)
            }
        )
        .coordinateSpace(name: RefreshControlView.coordinateSpace)
        .animation(.easeInOut, value: viewModel.selectedOption)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onAppear(perform: { viewModel.action.send(.fetchNewOffers) })
    }

    private var marketPlaceContent: some View {
        RefreshContainer(topPadding: Appearance.GridGuide.refreshContainerPadding,
                         hideRefresh: viewModel.isGraphExpanded,
                         isRefreshing: $viewModel.isRefreshing) {
            VStack(spacing: Appearance.GridGuide.mediumPadding1) {
                marketPlaceHeader

                marketplaceOfferList
            }
            .animation(.easeInOut, value: viewModel.marketplaceFeedItems)
        }
    }

    private var marketplaceOfferList: some View {
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

    private var marketPlaceHeader: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            MarketplaceSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            if !viewModel.isMarketplaceLocked {
                filter
            }
        }
    }

    @ViewBuilder
    private var filter: some View {
        switch viewModel.selectedOption {
        case .buy:
            MarketplaceFilterView(
                items: viewModel.buyFilters,
                hasFilters: viewModel.userSelectedFilters,
                hasOffers: viewModel.createdBuyOffers,
                mainAction: {
                    viewModel.action.send(.showBuyOffer)
                }
            )
            .animation(.easeInOut, value: viewModel.userSelectedFilters)
        case .sell:
            MarketplaceFilterView(
                items: viewModel.sellFilters,
                hasFilters: viewModel.userSelectedFilters,
                hasOffers: viewModel.createdSellOffers,
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
