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
            .animation(.easeInOut)
    }

    private var content: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            MarketplaceSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            filter

            ScrollView {
                ForEach(viewModel.feedItems) { item in
                    MarketplaceFeedView(title: item.title,
                                        isRequested: item.isRequested,
                                        location: item.location,
                                        maxAmount: item.maxAmount,
                                        paymentMethod: item.paymentMethod,
                                        fee: item.fee)
                        .padding(.horizontal, Appearance.GridGuide.point)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .cornerRadius(Appearance.GridGuide.padding)
    }

    private var filter: some View {
        switch viewModel.selectedOption {
        case .buy:
            return MarketplaceFilterView(items: viewModel.buyFilters,
                                         actionTitle: L.marketplaceBuyAdd(),
                                         filterAction: { index in
                print("filter from \(index) has been tapped")
            },
                                     action: {
                print("+ is pressed")
            })
        case .sell:
            return MarketplaceFilterView(items: viewModel.sellFilters,
                                         actionTitle: L.marketplaceSellOffer(),
                                         filterAction: { index in
                print("filter from \(index) has been tapped")
            },
                                     action: {
                viewModel.action.send(.showOffer)
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