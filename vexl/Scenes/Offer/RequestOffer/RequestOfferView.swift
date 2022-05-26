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
    @State var text: String = ""

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

    private var header: some View {
        HStack {
            Text("Offer")
                .textStyle(.h2)
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(maxWidth: .infinity, alignment: .leading)

            closeButton
        }
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: Appearance.GridGuide.padding) {
                offer

                commonFriendsContainer

                ExpandingTextView(
                    placeholder: "e.g. let’s trade my friend...",
                    text: $text
                )

                SolidButton(Text("Send request"),
                            font: Appearance.TextStyle.titleSmallBold.font.asFont,
                            colors: SolidButtonColor.main,
                            dimensions: SolidButtonDimension.largeButton,
                            action: {
                    viewModel.send(action: .dismissTap)
                })
            }
        }
    }

    private var offer: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferFeedDetailView(
                title: "Test df",
                maxAmount: "Up to 10K czk",
                paymentLabel: "Something",
                paymentIcons: [],
                offerType: .buy,
                isRequested: false
            )

            AvatarInfo(
                isAvatarWithOpacity: false,
                title: "Murakami is selling",
                subtitle: "Friend of friend"
            )
        }
        .padding(.top, Appearance.GridGuide.padding)
    }

    private var commonFriendsContainer: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.point) {
            Text("16 common friends")
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

#if DEBUG || DEVEL
struct RequestOfferViewPreview: PreviewProvider {
    static var previews: some View {
        RequestOfferView(viewModel: .init())
    }
}
#endif
