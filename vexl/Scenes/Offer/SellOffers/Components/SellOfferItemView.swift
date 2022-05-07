//
//  UserOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import SwiftUI

typealias SellOfferViewData = SellOfferItemView.ViewData

struct SellOfferItemView: View {

    let data: ViewData

    var body: some View {
        VStack {
            HStack {
                Button {
                    // TODO: - Implement action
                } label: {
                    Image(R.image.offer.dottedButton.name)
                        .frame(size: Appearance.GridGuide.thumbSize)
                }
                .background(Appearance.Colors.gray6)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            Text(data.description)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding(.top, Appearance.GridGuide.point)

            HStack {
                VStack(spacing: Appearance.GridGuide.tinyPadding) {
                    Text("\(data.currency)\(data.minAmount)")
                        .multilineTextAlignment(.center)
                        .textStyle(.paragraph)
                        .foregroundColor(Appearance.Colors.gray2)
                        .frame(maxWidth: .infinity)

                    Text("\(data.currency)\(data.maxAmount)")
                        .multilineTextAlignment(.center)
                        .textStyle(.paragraph)
                        .foregroundColor(Appearance.Colors.gray2)
                        .frame(maxWidth: .infinity)

                    Text(L.offerSellAmountToSell())
                        .multilineTextAlignment(.center)
                        .textStyle(.description)
                        .foregroundColor(Appearance.Colors.gray2)
                        .frame(maxWidth: .infinity)
                }

                Divider()

                VStack {
                    ForEach(data.paymentMethods, id: \.self) { method in
                        Text(method)
                            .textStyle(.description)
                            .foregroundColor(Appearance.Colors.gray2)
                            .padding(.bottom, Appearance.GridGuide.tinyPadding)
                    }
                }
                .frame(maxWidth: .infinity)

                Divider()

                Text(L.offerSellNoLocation())
                    .multilineTextAlignment(.center)
                    .textStyle(.description)
                    .foregroundColor(Appearance.Colors.gray2)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, Appearance.GridGuide.padding)
        }
        .padding(Appearance.GridGuide.padding)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension SellOfferItemView {
    struct ViewData: Identifiable, Hashable {
        let id: String
        let description: String
        let minAmount: Int
        let maxAmount: Int
        let paymentMethods: [String]
        let currency = "$"
    }
}

#if DEBUG || DEVEL
struct SellOfferItemViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            SellOfferItemView(data: .init(id: "123",
                                          description: "Hello World 1234 1234",
                                          minAmount: 10_000,
                                          maxAmount: 40_000,
                                          paymentMethods: ["Bank", "Revolut"]))
        }
        .frame(maxHeight: .infinity)
        .previewDevice("iPhone 11")
        .background(Color.black)
    }
}
#endif
