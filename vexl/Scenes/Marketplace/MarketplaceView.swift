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
        VStack(spacing: 0) {
            BitcoinView(viewModel: viewModel.bitcoinViewModel)
            marketPlaceHeader
                .background(Color.black)
                .cornerRadius(Appearance.GridGuide.buttonCorner, corners: [.topLeft, .topRight])

            marketPlaceContent
        }
        .padding(.horizontal, Appearance.GridGuide.tinyPadding)
        .coordinateSpace(name: RefreshControlView.coordinateSpace)
        .animation(.easeInOut, value: viewModel.selectedOption)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onAppear(perform: { viewModel.action.send(.fetchNewOffers) })
    }

    @ViewBuilder private var marketPlaceContent: some View {
        if viewModel.isMarketplaceLocked {
            marketPlaceHeader
        } else {
            OffsetScrollView(
                offsetChanged: { offset in
                    if offset.y > Constants.pullToRefreshActivationOffset {
                        viewModel.send(action: .fetchNewOffers)
                    }
                },
                content: {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.marketplaceFeedItems) { item in
                            MarketplaceFeedView(data: item,
                                                displayFooter: false,
                                                requestAction: { _ in
                                viewModel.action.send(.offerTapped(offer: item.offer))
                            })
                            .onTapGesture {
                                if !item.isRequested {
                                    viewModel.action.send(.offerTapped(offer: item.offer))
                                }
                            }
                        }
                        Rectangle()
                            .frame(height: Appearance.GridGuide.homeTabBarHeight)
                    }
                }
            )
        }
    }

    private var marketPlaceHeader: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            MarketplaceSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            if !viewModel.isMarketplaceLocked {
                ZStack {
                    filter
                    if viewModel.isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
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
            .id("MarketplaceSellFilter")
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
            .id("MarketplaceBuyFilter")
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
