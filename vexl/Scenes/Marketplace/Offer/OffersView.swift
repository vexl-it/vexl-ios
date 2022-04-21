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
            HStack(alignment: .bottom) {
                Text("My Sell Offers")
                    .textStyle(.h1)
                    .foregroundColor(Appearance.Colors.whiteText)

                Spacer()

                Button {
                    viewModel.action.send(.dismissTap)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                        .padding(Appearance.GridGuide.point)
                        .background(Appearance.Colors.gray1)
                        .cornerRadius(Appearance.GridGuide.point)
                }
                .padding(.bottom, Appearance.GridGuide.point)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)

            Rectangle()
                .foregroundColor(Color.white)
                .frame(height: 3)
                .padding(.horizontal, Appearance.GridGuide.point)

            Button {
                viewModel.action.send(.createOfferTap)
            } label: {
                Text("+ New Sell Offer")
                    .textStyle(.descriptionSemibold)
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
