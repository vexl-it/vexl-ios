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
                        commonFriendsContainer

                        ExpandingTextView(
                            placeholder: L.requestPlaceholder(),
                            text: $viewModel.requestText
                        )

                        Spacer()

                        SolidButton(Text(L.requestButton()),
                                    font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                    colors: SolidButtonColor.main,
                                    dimensions: SolidButtonDimension.largeButton,
                                    action: { viewModel.send(action: .sendRequest) })
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
                title: viewModel.offerFeed.title,
                maxAmount: viewModel.offerFeed.amount,
                paymentLabel: viewModel.offerFeed.paymentLabel,
                paymentIcons: viewModel.offerFeed.paymentIcons,
                offerType: viewModel.offerFeed.offerType,
                isRequested: false,
                useInnerPadding: true,
                showBackground: true
            )

            ContactAvatarInfo(
                isAvatarWithOpacity: false,
                title: "Murakami is selling",
                subtitle: viewModel.offerFeed.friendLevel
            )
        }
        .padding(.top, Appearance.GridGuide.padding)
    }

    private var commonFriendsContainer: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            Text(L.requestCommonFriends(16))
                .textStyle(.descriptionSemiBold)
                .foregroundColor(Appearance.Colors.gray3)
                .frame(maxWidth: .infinity, alignment: .leading)

            commonFriends
        }
        .padding()
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.containerCorner)
    }

    private var commonFriends: some View {
        HStack {
            Circle()
                .fill(.white)
                .frame(size: Appearance.GridGuide.iconSize)

            Text("Diego E.")
                .textStyle(.paragraphSmall)
                .foregroundColor(Appearance.Colors.gray3)
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
