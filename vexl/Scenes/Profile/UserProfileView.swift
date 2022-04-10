//
//  UserProfileView.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import SwiftUI
import Combine

struct UserProfileView: View {

    @ObservedObject var viewModel: UserProfileViewModel

    private let headerHeight: CGFloat = 150

    var body: some View {
        VStack {

            CoinVariationHeaderView(currencySymbol: viewModel.currencySymbol,
                                    amount: viewModel.amount)

            Spacer()

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Appearance.Colors.green1.edgesIgnoringSafeArea(.all))
    }

    private var content: some View {
        VStack {
            HStack {
                avatarImage
                    .frame(width: Appearance.GridGuide.baseHeight,
                           height: Appearance.GridGuide.baseHeight)
                    .cornerRadius(Appearance.GridGuide.baseHeight * 0.5,
                                  corners: .allCorners)

                Text(viewModel.username)
                    .textStyle(.h1)
                    .foregroundColor(.white)
                    .padding(.leading, Appearance.GridGuide.padding)

                Spacer()
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.vertical, Appearance.GridGuide.mediumPadding2)

            Color.white
                .frame(height: 3)
                .padding(.horizontal, Appearance.GridGuide.point)

            List {
                ForEach(viewModel.options) { group in
                    Section {
                        ForEach(group.options) { item in
                            Item(title: item.title,
                                 subtitle: item == .contacts ? item.subtitle(withParam: viewModel.contacts) : item.subtitle(),
                                 icon: item.iconName)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .onAppear {
                UITableView.appearance().backgroundColor = UIColor.clear
            }
            .padding(.horizontal, -Appearance.GridGuide.point)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black)
        .cornerRadius(Appearance.GridGuide.padding,
                      corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
    }

    @ViewBuilder private var avatarImage: some View {
        if let data = viewModel.avatar, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
        } else {
            Image(R.image.onboarding.emptyAvatar.name)
                .resizable()
        }
    }
}

extension UserProfileView {
    struct Item: View {

        let title: String
        let subtitle: String?
        let icon: String

        var body: some View {
            HStack {

                Image(icon)
                    .resizable()
                    .frame(size: Appearance.GridGuide.iconSize)

                VStack(alignment: .leading) {
                    Text(title)
                        .textStyle(.paragraph)
                        .foregroundColor(.white)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .textStyle(.micro)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
            }
            .listRowBackground(Appearance.Colors.black1)
            .frame(height: Appearance.GridGuide.largeButtonHeight)
            .padding(.vertical, 0)
        }
    }
}

struct UserProfileViewPreview: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
