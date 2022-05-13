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

    var body: some View {
        content
            .background(Color.black.edgesIgnoringSafeArea(.bottom))
            .cornerRadius(Appearance.GridGuide.buttonCorner,
                          corners: [.topLeft, .topRight])
            .transaction { transaction in
                transaction.animation = .easeInOut(duration: 0.25)
            }
    }

    private var content: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            MarketplaceSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            filter

            ScrollView {
                Group {
                    ForEach(viewModel.marketplaceFeedItems) { item in
                        MarketplaceFeedView(data: item,
                                            displayFooter: false)
                            .padding(.horizontal, Appearance.GridGuide.point)
                    }
                }
                .padding(.bottom, Appearance.GridGuide.homeTabBarHeight)
            }
            .transaction { transaction in
                transaction.animation = nil
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .cornerRadius(Appearance.GridGuide.padding)
    }

    private var filter: some View {
        switch viewModel.selectedOption {
        case .buy:
            return MarketplaceFilterView(items: viewModel.buyFilters,
                                         actionTitle: L.marketplaceSellOffer(),
                                         filterAction: { index in
                print("filter from \(index) has been tapped")
            },
                                     action: {
                viewModel.action.send(.showBuyOffer)
            })
        case .sell:
            return MarketplaceFilterView(items: viewModel.sellFilters,
                                         actionTitle: L.marketplaceSellOffer(),
                                         filterAction: { index in
                print("filter from \(index) has been tapped")
            },
                                     action: {
                viewModel.action.send(.showSellOffer)
            })
        }
    }
}

#if DEBUG || DEVEL
struct BuySellViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
#endif
