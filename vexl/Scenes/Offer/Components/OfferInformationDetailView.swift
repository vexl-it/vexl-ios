//
//  OfferInformationDetailView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

typealias OfferDetailViewData = OfferInformationDetailView.ViewData

struct OfferInformationDetailView: View {
    @ObservedObject var data: ViewData
    let useInnerPadding: Bool
    let showBackground: Bool
    @State private var lineSize: CGSize = .zero

    private var paymentLayoutStyle: OfferPaymentIconView.LayoutStyle {
        OfferPaymentIconView.LayoutStyle(icons: data.paymentIcons)
    }

    private var backgroundColor: Color {
        guard showBackground else {
            return Color.clear
        }
        return data.isRequested ? Appearance.Colors.gray1 : Appearance.Colors.whiteText
    }

    private var textColor: Color {
        guard showBackground else {
            return Appearance.Colors.primaryText
        }
        return data.isRequested ? Appearance.Colors.gray3 : Appearance.Colors.primaryText
    }

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(data.title)
                .textStyle(.paragraphMedium)
                .multilineTextAlignment(.leading)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, useInnerPadding ? Appearance.GridGuide.mediumPadding1 : 0)

            detail
        }
        .padding(.horizontal, useInnerPadding ? Appearance.GridGuide.padding : 0)
        .background(backgroundColor)
        .cornerRadius(showBackground ? Appearance.GridGuide.buttonCorner : 0)
    }

    private var detail: some View {
        HStack {
            DetailItem(label: data.offerType == .buy ? L.marketplaceDetailBuy() : L.marketplaceDetailSell(), content: {
                Text(L.marketplaceDetailUpTo(data.amount))
                    .foregroundColor(Appearance.Colors.gray2)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            })
            .readSize(onChange: { size in
                lineSize = size
            })
            .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)
                .frame(maxHeight: lineSize.height)

            DetailItem(label: data.paymentLabel, content: {
                OfferPaymentIconView(layoutStyle: paymentLayoutStyle)
            })
            .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)
                .frame(maxHeight: lineSize.height)

            // TODO: - Set real location when it is implemented

            DetailItem(label: "Prague", content: {
                Image(R.image.marketplace.mapPin.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedIconSize)
            })
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, useInnerPadding ? Appearance.GridGuide.padding : 0)
    }
}

extension OfferInformationDetailView {

    private struct DetailItem<Content: View>: View {
        let label: String
        let content: () -> Content
        private let maxHeight: CGFloat = 80

        var body: some View {
            VStack {
                content()
                    .frame(maxHeight: maxHeight)

                Text(label)
                    .textStyle(.descriptionSemiBold)
                    .foregroundColor(Appearance.Colors.gray3)
                    .padding(.top, Appearance.GridGuide.point)
            }
        }
    }
}

extension OfferInformationDetailView {

    final class ViewData: Identifiable, Hashable, ObservableObject {
        static func == (lhs: OfferInformationDetailView.ViewData, rhs: OfferInformationDetailView.ViewData) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        let offer: ManagedOffer

        @Published var isRequested: Bool = false
        @Published var id: String = UUID().uuidString
        @Published var avatar: Data?
        @Published var username: String = L.generalAnonymous()
        @Published var title: String = ""
        @Published var friendLevel: String = OfferFriendDegree.firstDegree.rawValue
        @Published var paymentMethods: [OfferPaymentMethodOption] = []
        @Published var fee: String?
        @Published var offerType: OfferType = .buy
        @Published var createdDate: Date = Date()

        var amount: String {
            guard let currency = offer.currency else { return "" }
            let maxAmount = Int(offer.maxAmount)
            return currency.formattedCurrency(amount: maxAmount)
        }

        var paymentIcons: [String] {
            paymentMethods.map(\.iconName)
        }

        var paymentLabel: String {
            guard let label = paymentMethods.first?.title else {
                return Constants.notAvailable
            }

            if paymentMethods.count > 1 {
                return "\(label) +(\(paymentMethods.count - 1))"
            }

            return label
        }

        init(offer: ManagedOffer) {
            self.offer = offer
            let profile = offer.receiversPublicKey?.profile

            offer.publisher(for: \.isRequested).assign(to: &$isRequested)
            offer.publisher(for: \.id).filterNil().assign(to: &$id)
            profile?.publisher(for: \.avatarData).compactMap { _ in profile?.avatar }.assign(to: &$avatar)
            profile?.publisher(for: \.name).filterNil().assign(to: &$username)
            offer.publisher(for: \.offerDescription).filterNil().assign(to: &$title)
            offer.publisher(for: \.friendDegreeRawType).map { _ in offer.friendLevel?.label }.filterNil().assign(to: &$friendLevel)
            offer.paymentMethodsPublisher.assign(to: &$paymentMethods)
            offer.publisher(for: \.feeAmount).filter { $0 > 0 }.map { "\($0)%" }.filterNil().assign(to: &$fee)
            offer.publisher(for: \.offerTypeRawType).map { _ in offer.type }.filterNil().assign(to: &$offerType)
            offer.publisher(for: \.createdAt).filterNil().assign(to: &$createdDate)
        }

        static var stub: OfferDetailViewData {
            OfferDetailViewData(offer: .stub)
        }
    }
}

#if DEBUG || DEVEL
struct MarketplaceFeedDetailViewPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            OfferInformationDetailView(
                data: .stub,
                useInnerPadding: false,
                showBackground: true
            )
            .frame(height: 250)
        }
    }
}
#endif
