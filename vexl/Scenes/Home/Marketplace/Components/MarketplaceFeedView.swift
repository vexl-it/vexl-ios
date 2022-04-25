//
//  BuySellInformationView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import SwiftUI

typealias MarketplaceFeedViewData = MarketplaceFeedView.ViewData

struct MarketplaceFeedView: View {

    let title: String
    let isRequested: Bool
    let location: String

    let maxAmount: String
    let paymentMethod: String
    let fee: String?

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(title)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding([.horizontal, .top], Appearance.GridGuide.mediumPadding1)

            MarketplaceFeedDetailView(maxAmount: maxAmount,
                                      paymentMethod: paymentMethod,
                                      fee: fee)
                .padding(.horizontal, Appearance.GridGuide.padding)

            // TODO: - set contact type from viewmodel + real action
            MarketplaceFeedFooterView(contactType: .facebook,
                                      isRequested: isRequested,
                                      location: location) {
                print("facebook")
            }
                .padding(.horizontal, Appearance.GridGuide.padding)
                .padding(.bottom, Appearance.GridGuide.padding)
        }
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension MarketplaceFeedView {

    struct ViewData: Identifiable {
        let id: Int
        let title: String
        let isRequested: Bool
        let location: String

        let maxAmount: String
        let paymentMethod: String
        let fee: String?
    }
}

#if DEBUG || DEVEL
struct MarketplaceFeedViewViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceFeedView(title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                            isRequested: true,
                            location: "Prague",
                            maxAmount: "up to $10K",
                            paymentMethod: "Revolut",
                            fee: nil)
            .previewDevice("iPhone 11")
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.black)
    }
}
#endif
