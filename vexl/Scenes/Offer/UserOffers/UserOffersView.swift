//
//  OffersView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import SwiftUI

struct UserOffersView: View {

    @ObservedObject var viewModel: UserOffersViewModel

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            HeaderTitleView(title: viewModel.offerTitle, showsSeparator: true) {
                viewModel.action.send(.dismissTap)
            }

            OfferSortView(numberOfOffers: viewModel.activeOfferCount,
                          sortingOption: $viewModel.offerSortingOption)

            LabelButton(
                isEnabled: .constant(true),
                backgroundColor: Appearance.Colors.pink20,
                content: {
                    offerLabel
                }, action: {
                    viewModel.action.send(.createOfferTap)
                }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: Appearance.GridGuide.mediumPadding1) {
                    ForEach(viewModel.offerItems) { offerData in
                        OfferItemView(
                            data: offerData,
                            editOfferAction: {
                                viewModel.action.send(.editOfferTap(offer: offerData.offer))
                            }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var offerLabel: some View {
        HStack(alignment: .center) {
            Image(systemName: "plus")

            Text(viewModel.createOfferTitle)
                .textStyle(.descriptionBold)
        }
        .foregroundColor(Appearance.Colors.pink100)
    }
}

#if DEBUG || DEVEL
struct OffersViewPreview: PreviewProvider {
    static var previews: some View {
        UserOffersView(viewModel: .init(offerType: .sell))
            .previewDevice("iPhone 11")
    }
}
#endif
