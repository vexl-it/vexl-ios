//
//  RequestOfferView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import SwiftUI
import Cleevio

struct RequestOfferView: View {
    @ObservedObject var viewModel: RequestOfferViewModel

    private var scrollViewBottomPadding: CGFloat {
        Appearance.GridGuide.baseHeight + Appearance.GridGuide.padding * 2
    }

    private var avatarTitle: String {
        switch viewModel.offerViewData.offerType {
        case .sell:
            return L.marketplaceDetailUserSell(viewModel.username)
        case .buy:
            return L.marketplaceDetailUserBuy(viewModel.username)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            scrollableContent
        }
        .padding(.horizontal, Appearance.GridGuide.point)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

   @ViewBuilder private var header: some View {
        switch viewModel.state {
        case .normal:
            normalHeader
        case .requesting:
            requestingHeader
        }
    }

    private var normalHeader: some View {
        HStack {
            Text(L.requestTitleNormal())
                .textStyle(.h2)
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(maxWidth: .infinity, alignment: .leading)

            closeButton
        }
    }

    private var requestingHeader: some View {
        HStack(alignment: .bottom) {
            Text(L.requestTitleRequesting())
                .textStyle(.h2)
                .foregroundColor(Appearance.Colors.whiteText)

            LoadingDotsView()
                .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var closeButton: some View {
        Button(action: { viewModel.send(action: .dismissTap) }, label: {
            Image(systemName: "xmark")
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(size: Appearance.GridGuide.baseButtonSize)
        })
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Appearance.Colors.gray1)
        )
    }

    private var scrollableContent: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: Appearance.GridGuide.padding) {
                    offer

                    switch viewModel.state {
                    case .requesting:
                        Spacer()
                    case .normal:
                        if !viewModel.commonFriends.isEmpty {
                            commonFriendsContainer
                        }

                        ExpandingTextView(
                            placeholder: L.requestPlaceholder(),
                            text: $viewModel.requestText
                        )

                        Spacer()

                        LargeSolidButton(title: L.requestButton(),
                                         font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                         style: .main,
                                         isFullWidth: true,
                                         isEnabled: .constant(true),
                                         action: {
                            viewModel.send(action: .sendRequest)
                        })
                    }
                }
                .frame(minHeight: geometry.size.height)
                .animation(.easeInOut, value: viewModel.state)
            }
            .frame(width: geometry.size.width)
        }
    }

    private var offer: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferInformationDetailView(
                data: viewModel.offerViewData,
                useInnerPadding: true,
                showBackground: true
            )

            ContactAvatarInfo(
                isAvatarWithOpacity: false,
                title: avatarTitle,
                subtitle: viewModel.offerViewData.friendLevel,
                avatar: viewModel.offerViewData.avatar
            )
        }
        .padding(.top, Appearance.GridGuide.padding)
    }

    private var commonFriendsContainer: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            Text(L.requestCommonFriends(viewModel.commonFriends.count))
                .textStyle(.descriptionSemiBold)
                .foregroundColor(Appearance.Colors.gray3)
                .frame(maxWidth: .infinity, alignment: .leading)

            commonFriends
        }
        .padding()
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.containerCorner)
    }

    @ViewBuilder
    private var commonFriends: some View {
        let chunks = viewModel.commonFriends.splitIntoChunks(by: 2)
        ForEach(Array(chunks.enumerated()), id: \.offset) { chunk in
            VStack {
                HStack {
                    ForEach(chunk.element) { contact in
                        Image(data: contact.avatar, placeholder: "PinFaceId")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(size: Appearance.GridGuide.iconSize)

                        Text(contact.name ?? "")
                            .textStyle(.paragraphSmall)
                            .foregroundColor(Appearance.Colors.gray3)
                    }
                }
            }
        }
    }
}

extension VerticalAlignment {
    private enum BottomTextAndLoading: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            dimensions[.bottom]
        }
    }

    static let bottomTextAndLoading = VerticalAlignment(BottomTextAndLoading.self)
}

#if DEBUG || DEVEL
struct RequestOfferViewPreview: PreviewProvider {
    static var previews: some View {
        let viewModel: RequestOfferViewModel = {
            let vm = RequestOfferViewModel(offer: .stub)
            vm.state = .requesting
            return vm
        }()
        return RequestOfferView(viewModel: viewModel)
    }
}
#endif
