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

    private var userActionTitle: String {
        viewModel.offerViewData.offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("")
    }

    private var userActionTitleColor: UIColor {
        viewModel.offerViewData.offerType == .buy ? UIColor(Appearance.Colors.green100) : UIColor(Appearance.Colors.pink100)
    }

    private var avatarTitle: NSAttributedString {
        let userTitle = NSMutableAttributedString(
            string: viewModel.username,
            attributes: [.font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                         .foregroundColor: UIColor(Appearance.Colors.whiteText)]
        )
        let actionTitle = NSAttributedString(
            string: userActionTitle,
            attributes: [.font: Appearance.TextStyle.paragraphSmallSemiBold.font,
                         .foregroundColor: userActionTitleColor]
        )

        userTitle.append(actionTitle)

        return userTitle
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

            flagButton

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

    private var flagButton: some View {
        Button(action: { viewModel.send(action: .flagTap) }, label: {
            Image(R.image.marketplace.flag.name)
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
                            text: $viewModel.requestText,
                            isFirstResponder: false
                        )

                        Spacer()

                        LargeSolidButton(title: L.requestButton(),
                                         iconImage: Image(R.image.marketplace.eyeBlack.name),
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
                showArrowIndicator: false,
                showBackground: true
            )
            .clipShape(
                MarketplaceItemShape(horizontalStartPoint: Appearance.GridGuide.feedAvatarSize.width)
            )

            ContactAvatarInfo(
                isAvatarWithOpacity: false,
                titleType: .attributed(avatarTitle),
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Appearance.GridGuide.padding) {
                ForEach(viewModel.commonFriends) { contact in
                    HStack {
                        Image(data: contact.avatar, placeholder: R.image.marketplace.defaultAvatar.name)
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
