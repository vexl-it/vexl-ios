//
//  BuySellInformationView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import SwiftUI

typealias MarketplaceFeedViewData = MarketplaceFeedView.ViewData

struct MarketplaceFeedView: View {

    let data: ViewData
    let displayFooter: Bool

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(data.title)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding([.horizontal, .top], Appearance.GridGuide.mediumPadding1)

            MarketplaceFeedDetailView(maxAmount: data.amount,
                                      paymentMethod: data.paymentMethodDisplayValue,
                                      fee: data.fee)
                .padding(displayFooter ? [.horizontal] : [.horizontal, .bottom],
                         Appearance.GridGuide.padding)

            if displayFooter {
                // TODO: - set contact type from viewmodel + real action
                MarketplaceFeedFooterView(contactType: .phone,
                                          isRequested: data.isRequested,
                                          location: data.location) {
                    print("facebook")
                }
                .padding([.horizontal, .bottom], Appearance.GridGuide.padding)
            }
        }
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension MarketplaceFeedView {

    struct ViewData: Identifiable {
        let id: String
        let title: String
        let isRequested: Bool
        let location: String

        let amount: String
        let paymentMethods: [String]
        let fee: String?

        var paymentMethodDisplayValue: String {
            paymentMethods.joined(separator: "\n")
        }
    }
}

#if DEBUG || DEVEL
struct MarketplaceFeedViewViewPreview: PreviewProvider {
    static var previews: some View {
        let data = MarketplaceFeedViewData(id: "1",
                                           title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                                           isRequested: false,
                                           location: "Prague",
                                           amount: "$10k - $20k",
                                           paymentMethods: ["Revolut"],
                                           fee: nil)
        MarketplaceFeedView(data: data,
                            displayFooter: false)
            .previewDevice("iPhone 11")
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.black)
    }
}
#endif
