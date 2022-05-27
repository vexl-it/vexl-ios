//
//  ChatRequestView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

struct ChatRequestView: View {

    @ObservedObject var viewModel: ChatRequestViewModel

    var body: some View {
        VStack {
            HeaderTitleView(title: "2 Requests", showSeparator: false) {
                viewModel.action.send(.dismissTap)
            }
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
            .padding(.top, Appearance.GridGuide.largePadding1)

            TabView {
                ChatRequestOfferView()
                    .padding(.horizontal, Appearance.GridGuide.padding)
                ChatRequestOfferView()
                    .padding(.horizontal, Appearance.GridGuide.padding)
                ChatRequestOfferView()
                    .padding(.horizontal, Appearance.GridGuide.padding)
                ChatRequestOfferView()
                    .padding(.horizontal, Appearance.GridGuide.padding)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct ChatRequestOfferView: View {
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ScrollView(showsIndicators: false) {
                ContactAvatarInfo(isAvatarWithOpacity: false,
                                  title: "WASDWS",
                                  subtitle: "QWERTY",
                                  style: .large)
                    .padding(.horizontal, Appearance.GridGuide.padding)

                card
            }

            buttons
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit")
                .padding([.horizontal, .top], Appearance.GridGuide.mediumPadding1)
                .textStyle(.titleSmallMedium)

            friends
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.top, Appearance.GridGuide.padding)

            offer
        }
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.requestCorner)
        .padding(.top, Appearance.GridGuide.mediumPadding1)
    }

    private var offer: some View {
        VStack(alignment: .leading, spacing: .zero) {

            Text("Your offer")
                .textStyle(.descriptionSemiBold)
                .foregroundColor(Appearance.Colors.gray3)
                .padding([.horizontal, .top], Appearance.GridGuide.padding)

            OfferInformationDetailView(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                                       maxAmount: "10k",
                                       paymentLabel: "Payment",
                                       paymentIcons: [OfferPaymentMethodOption.revolut.iconName],
                                       offerType: .buy,
                                       isRequested: false,
                                       useInnerPadding: false,
                                       showBackground: false)
                .padding(Appearance.GridGuide.padding)
        }
            .background(Appearance.Colors.gray6)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .padding(Appearance.GridGuide.point)
    }

    private var friends: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("Friend 1 goes here")

                    Text("Friend 2 goes here")

                    Text("Friend 3 goes here")

                    Text("Friend 4 goes here")

                    Text("Friend 4 goes here")
                }
                .padding()
            }

            Image(systemName: "chevron.right")
                .foregroundColor(Appearance.Colors.gray3)
                .padding(.vertical, Appearance.GridGuide.padding)
                .padding(.horizontal, Appearance.GridGuide.point)
        }
        .background(Appearance.Colors.gray6)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var buttons: some View {
        HStack {
            Button("Decline", action: {
                print("Declined")
            })
                .textStyle(.titleSmallSemiBold)
                .foregroundColor(Appearance.Colors.yellow100)
                .frame(height: Appearance.GridGuide.largeButtonHeight)
                .frame(maxWidth: .infinity)
                .background(Appearance.Colors.yellow20)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

            Button("Accept", action: {
                print("Accept")
            })
                .textStyle(.titleSmallSemiBold)
                .foregroundColor(Appearance.Colors.primaryText)
                .frame(height: Appearance.GridGuide.largeButtonHeight)
                .frame(maxWidth: .infinity)
                .background(Appearance.Colors.yellow100)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.top, Appearance.GridGuide.largePadding2)
    }
}

#if DEVEL || DEBUG

struct ChatRequestViewPreview: PreviewProvider {
    static var previews: some View {
        ChatRequestView(viewModel: .init())
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}

#endif
