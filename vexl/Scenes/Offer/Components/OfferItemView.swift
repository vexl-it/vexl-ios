//
//  UserOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import SwiftUI

struct OfferItemView: View {

    enum UIProperties {
        static let editOfferButtonHeight: CGFloat = 48
    }

    let data: OfferFeedViewData
    let editOfferAction: () -> Void

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            bubble

            footer
        }
    }

    private var bubble: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(data.title)
                .textStyle(.paragraph)
                .multilineTextAlignment(.leading)
                .foregroundColor(data.isRequested ? Appearance.Colors.gray3 : Appearance.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Appearance.GridGuide.mediumPadding1)

            OfferFeedDetailView(maxAmount: data.amount,
                                paymentLabel: data.paymentLabel,
                                paymentIcons: data.paymentIcons,
                                offerType: data.offerType)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var footer: some View {
        HStack {
            AvatarInfo(
                isAvatarWithOpacity: false,
                title: "My offer",
                subtitle: "Added 12. 7. 2022"
            )

            Button(action: editOfferAction, label: {
                Text("Edit offer")
                    .foregroundColor(Appearance.Colors.yellow100)
            })
            .padding()
            .frame(height: UIProperties.editOfferButtonHeight)
            .background(Appearance.Colors.yellow20)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
struct OfferItemViewPreview: PreviewProvider {
    static var previews: some View {
        let data = OfferFeedViewData(
            id: "2",
            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
            isRequested: true,
            friendLevel: "Friend",
            amount: "$10k",
            paymentMethods: [.revolut],
            fee: nil,
            offerType: .buy
        )
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            OfferItemView(data: data, editOfferAction: {})
                .frame(height: 250)
        }
    }
}
#endif
