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

            Button {
                viewModel.action.send(.createOfferTap)
            } label: {
                HStack {
                    Image(systemName: "plus")

                    Text(L.offerSellNewOffer())
                        .textStyle(.descriptionSemibold)
                }
                .foregroundColor(Appearance.Colors.green5)
                .padding(Appearance.GridGuide.padding)
            }
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: Appearance.GridGuide.buttonCorner)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                    .foregroundColor(Appearance.Colors.green5)
            )
            .padding(Appearance.GridGuide.point)

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
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
