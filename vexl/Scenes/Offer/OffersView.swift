//
//  OffersView.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import SwiftUI

struct OffersView: View {

    @ObservedObject var viewModel: OffersViewModel

    var body: some View {
        VStack {
            OfferHeaderView {
                viewModel.action.send(.dismissTap)
            }

            DottedButton(color: Appearance.Colors.green5,
                         content: {
                offerLabel
            },
                         action: {
                viewModel.action.send(.createOfferTap)
            })

            Spacer()

            ScrollView(showsIndicators: false) {
                ForEach(viewModel.offerItems, id: \.self) { offerData in
                    SellOfferItemView(data: offerData)
                        .padding(.horizontal, Appearance.GridGuide.point)
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var offerLabel: some View {
        HStack {
            Image(systemName: "plus")

            Text(L.offerSellNewOffer())
                .textStyle(.descriptionSemibold)
        }
        .foregroundColor(Appearance.Colors.green5)
        .padding(Appearance.GridGuide.padding)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG || DEVEL
struct OffersViewPreview: PreviewProvider {
    static var previews: some View {
        OffersView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
#endif
