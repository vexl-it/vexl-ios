//
//  OfferInformationDetailView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

typealias OfferDetailViewData = OfferInformationDetailView.ViewData

struct OfferInformationDetailView: View {
    @ObservedObject var data: ViewData
    let useInnerPadding: Bool
    let showBackground: Bool
    @State private var lineSize: CGSize = .zero

    private let groupLogoSize: Double = 53
    private let groupLogoRotationAngle: Angle = .degrees(-20)
    private let groupLogoImagePadding = Appearance.GridGuide.smallPadding

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
        VStack(spacing: Appearance.GridGuide.smallPadding) {
            VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {

                if data.isGroupOffer, let name = data.groupName {
                    Text(L.offerWidgetGroupsInfo(name))
                        .textStyle(.descriptionSemiBold)
                        .foregroundColor(data.groupColor)
                        .padding(.vertical, Appearance.GridGuide.tinyPadding)
                        .padding(.horizontal, Appearance.GridGuide.point)
                        .background(
                            data.groupColor
                                .opacity(0.1)
                        )
                        .cornerRadius(Appearance.GridGuide.groupLabelCorner)
                }

                Text(data.title)
                    .textStyle(.titleSmallMedium)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, useInnerPadding ? Appearance.GridGuide.mediumPadding1 : 0)

            VStack(spacing: Appearance.GridGuide.smallPadding) {

                detail

                if case .withFee = data.feeOption, let feeAmount = data.feeAmount {
                    Text(L.marketplaceDetailFee(feeAmount))
                        .textStyle(.paragraphMedium)
                        .foregroundColor(Appearance.Colors.gray3)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.bottom, useInnerPadding ? Appearance.GridGuide.padding : 0)
        }
        .padding(.horizontal, useInnerPadding ? Appearance.GridGuide.padding : 0)
        .background(backgroundColor)
        .cornerRadius(showBackground ? Appearance.GridGuide.buttonCorner : 0)
        .overlay(
            groupLogo
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: -Appearance.GridGuide.padding, y: Appearance.GridGuide.point)
        )
    }

    @ViewBuilder
    private var groupLogo: some View {
        Group {
            if data.isGroupOffer {
                if let logoImage = data.groupImage {
                    logoImage
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: groupLogoSize - (2 * groupLogoImagePadding),
                            height: groupLogoSize - (2 * groupLogoImagePadding)
                        )
                        .padding(groupLogoImagePadding)
                        .background(data.groupColor)
                } else if let name = data.groupName {
                    EmptyGroupLogoSmall(name: .constant(name))
                }
            }
        }
        .frame(width: groupLogoSize, height: groupLogoSize)
        .cornerRadius(groupLogoSize / 2)
        .rotationEffect(groupLogoRotationAngle)
    }

    private var detail: some View {
        HStack {
            DetailItem(label: data.offerType == .buy ? L.marketplaceDetailBuy() : L.marketplaceDetailSell(), content: {
                HStack(alignment: .center, spacing: Appearance.GridGuide.tinyPadding) {
                    Text(L.marketplaceDetailUpTo().lowercased())
                        .textStyle(.microSemiBold)
                        .foregroundColor(Appearance.Colors.gray3)

                    Text(data.amount)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .textStyle(.titleSemiBold)
                        .foregroundColor(Appearance.Colors.gray3)
                }
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

            DetailItem(label: data.locationsTitle, content: {
                HStack(spacing: Appearance.GridGuide.point) {
                    if data.locationState != .online || data.containsLocation {
                        Image(R.image.marketplace.mapPin.name)
                            .resizable()
                            .frame(size: Appearance.GridGuide.feedIconSize)
                    }
                    if data.locationState == .online {
                        Image(R.image.marketplace.tradeOnline.name)
                            .resizable()
                            .frame(size: Appearance.GridGuide.feedIconSize)
                    }
                }
            })
            .frame(maxWidth: .infinity)
        }
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
        @Published var locationState: OfferTradeLocationOption?
        @Published var feeOption: OfferFeeOption = .withoutFee
        @Published var feeAmount: String?
        @Published var offerType: OfferType = .buy
        @Published var createdDate: Date = Date()
        @Published var locationsTitle: String = ""
        @Published var containsLocation: Bool = true

        @Published var isGroupOffer: Bool = false
        @Published var groupName: String?
        @Published var groupImage: Image?
        @Published var groupColor: Color
        @Published var offerLocations: [OfferLocation] = []

        var amount: String {
            guard let currency = offer.currency else { return "" }
            return currency.formattedShortCurrency(amount: offer.maxAmount)
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

        var attributedOfferTitle: NSAttributedString {
            let string = NSMutableAttributedString(string: username,
                                                   attributes: [.font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                                .foregroundColor: UIColor(Appearance.Colors.whiteText)])
            string.append(NSAttributedString(string: offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("") ,
                                             attributes: [.font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                                                          .foregroundColor: offerType == .buy ? UIColor(Appearance.Colors.green100) :
                                                                                                UIColor(Appearance.Colors.pink100)]))
            return string
        }

        private let cancelBag: CancelBag = .init()

        init(offer: ManagedOffer) {
            self.offer = offer
            let profile = offer.receiversPublicKey?.profile
            let group = offer.group

            groupColor = group?.color ?? Appearance.Colors.purple3

            offer.publisher(for: \.isRequested).assign(to: &$isRequested)
            offer.publisher(for: \.offerID).filterNil().assign(to: &$id)
            profile?.publisher(for: \.avatarData).compactMap { _ in profile?.avatar }.assign(to: &$avatar)
            profile?.publisher(for: \.name).filterNil().assign(to: &$username)
            offer.publisher(for: \.offerDescription).filterNil().assign(to: &$title)
            offer.publisher(for: \.friendDegreeRawType).map { _ in offer.friendLevel?.label }.filterNil().assign(to: &$friendLevel)
            offer.paymentMethodsPublisher.assign(to: &$paymentMethods)
            offer.publisher(for: \.feeStateRawType).compactMap { _ in offer.feeState }.assign(to: &$feeOption)
            offer.publisher(for: \.feeAmount).map { Formatters.numberFormatter.string(from: NSNumber(value: $0)) }.filterNil().assign(to: &$feeAmount)
            offer.publisher(for: \.offerTypeRawType).map { _ in offer.currentUserPerspectiveOfferType }.filterNil().assign(to: &$offerType)
            offer.publisher(for: \.createdAt).filterNil().assign(to: &$createdDate)
            offer.publisher(for: \.group).map { $0 != nil }.assign(to: &$isGroupOffer)
            offer.publisher(for: \.locationStateRawType).map { _ in offer.locationState }.assign(to: &$locationState)
            offer
                .publisher(for: \.locations)
                .compactMap { locationsSet -> [OfferLocation]? in
                    guard let locations = locationsSet as? Set<ManagedOfferLocation> else { return nil }
                    return locations.compactMap(OfferLocation.init)
                }
                .assign(to: &$offerLocations)

            group?.publisher(for: \.name).assign(to: &$groupName)
            group?.publisher(for: \.logo).map { $0.flatMap(UIImage.init).flatMap(Image.init) }.assign(to: &$groupImage)

            $offerLocations
                .map(\.isEmpty.not)
                .assign(to: &$containsLocation)

            let onlineTitle = offer
                .publisher(for: \.locationStateRawType)
                .map { _ in offer.locationState }
                .map {
                    $0 == .online ? L.offerCreateTradeStyleOnline() : nil
                }

            Publishers.CombineLatest($offerLocations, onlineTitle)
                .map { (cities: [OfferLocation], onlineTitle: String?) -> [String?] in
                    if onlineTitle == nil {
                        return Array(cities.map(\.city).prefix(upTo: min(2, cities.count)))
                    } else {
                        let firstCity = cities.first?.city
                        return [firstCity, onlineTitle]
                    }
                }
                .map { titles in
                    titles
                        .compactMap { $0 }
                        .joined(separator: ", ")
                }
                .assign(to: &$locationsTitle)
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
