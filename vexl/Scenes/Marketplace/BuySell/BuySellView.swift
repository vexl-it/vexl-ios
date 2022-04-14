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
        content
            .background(Color.black.edgesIgnoringSafeArea(.bottom))
            .cornerRadius(Appearance.GridGuide.buttonCorner,
                          corners: [.topLeft, .topRight])
    }

    private var content: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            BuySellSegmentView(selectedOption: $viewModel.selectedOption)
                .padding(.top, Appearance.GridGuide.mediumPadding2)

            filter

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

    private var filter: some View {
        switch viewModel.selectedOption {
        case .buy:
            return BuySellFilterView(items: viewModel.buyFilters,
                                     actionTitle: "+",
                                     filterAction: { index in
                print("filter from \(index) has been tapped")
            },
                                     action: {
                print("+ is pressed")
            })
        case .sell:
            return BuySellFilterView(items: viewModel.sellFilters,
                                     actionTitle: "Offer",
                                     filterAction: { index in
                print("filter from \(index) has been tapped")
            },
                                     action: {
                viewModel.route.send(.showOffer)
            })
        }
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
