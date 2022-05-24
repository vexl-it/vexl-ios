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
    let detailAction: (String) -> Void
    let requestAction: (String) -> Void

    var body: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            VStack(spacing: Appearance.GridGuide.padding) {
                Text(data.title)
                    .textStyle(.paragraph)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(data.isRequested ? Appearance.Colors.gray3 : Appearance.Colors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Appearance.GridGuide.mediumPadding1)

                MarketplaceFeedDetailView(maxAmount: data.amount,
                                          paymentMethod: data.paymentMethodDisplayValue,
                                          fee: data.fee)
                    .padding(.bottom, displayFooter ? 0 : Appearance.GridGuide.padding)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .background(data.isRequested ? Appearance.Colors.gray1 : Appearance.Colors.whiteText)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .onTapGesture {
                detailAction(data.id)
            }

            // TODO: - set contact type from viewmodel + real action

            MarketplaceFeedFooterView(isRequested: data.isRequested,
                                      friendLevel: data.friendLevel) {
                requestAction(data.id)
            }
            .padding(.bottom, Appearance.GridGuide.padding)
        }
    }
}

extension MarketplaceFeedView {

    struct ViewData: Identifiable {
        let id: String
        let title: String
        let isRequested: Bool
        let friendLevel: String

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
                                           friendLevel: "Friend",
                                           amount: "$10k",
                                           paymentMethods: ["Revolut"],
                                           fee: nil)

        let data2 = MarketplaceFeedViewData(id: "2",
                                            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
                                            isRequested: true,
                                            friendLevel: "Friend",
                                            amount: "$10k",
                                            paymentMethods: ["Revolut"],
                                            fee: nil)
        MarketplaceFeedView(data: data,
                            displayFooter: false,
                            detailAction: { _ in },
                            requestAction: { _ in })
            .previewDevice("iPhone 11")
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color.black)

        MarketplaceFeedView(data: data2,
                            displayFooter: true,
                            detailAction: { _ in },
                            requestAction: { _ in })
            .previewDevice("iPhone 11")
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color.black)
    }
}
#endif
