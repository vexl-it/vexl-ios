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
            ContactAvatarInfo(isAvatarWithOpacity: false,
                              title: "WASDWS",
                              subtitle: "QWERTY",
                              style: .large)
                .padding(.horizontal, Appearance.GridGuide.padding)

            VStack {
                Text("Hello")
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Appearance.Colors.whiteText)
            .cornerRadius(Appearance.GridGuide.requestCorner)
            .padding(.top, Appearance.GridGuide.mediumPadding1)

            HStack {
                Button("Decline", action: {
                    
                })
                    .textStyle(.titleSmallSemiBold)
                    .foregroundColor(Appearance.Colors.yellow100)
                    .frame(height: Appearance.GridGuide.largeButtonHeight)
                    .frame(maxWidth: .infinity)
                    .background(Appearance.Colors.yellow20)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)

                Button("Accept", action: {
                    
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
