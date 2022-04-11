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

    var body: some View {
        VStack {
            CoinVariationHeaderView(currencySymbol: viewModel.currencySymbol,
                                    amount: viewModel.amount)

            Spacer()

            content
        }
        .background(Appearance.Colors.green1.edgesIgnoringSafeArea(.all))
    }

    private var content: some View {
        VStack {
            HStack(spacing: Appearance.GridGuide.padding) {
                avatarImage

                Text(viewModel.username)
                    .textStyle(.h1)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.vertical, Appearance.GridGuide.mediumPadding2)

            LineDivider()

            profileItems
        }
        .background(Color.black)
        .cornerRadius(Appearance.GridGuide.padding,
                      corners: [.topLeft, .topRight])
        .edgesIgnoringSafeArea(.bottom)
    }

    private var avatarImage: some View {
        var image: Image
        if let data = viewModel.avatar, let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        } else {
            image = Image(R.image.onboarding.emptyAvatar.name)
        }
        return image
            .resizable()
            .frame(width: Appearance.GridGuide.baseHeight, height: Appearance.GridGuide.baseHeight)
            .cornerRadius(Appearance.GridGuide.baseHeight * 0.5, corners: .allCorners)
    }

    @ViewBuilder private var profileItems: some View {
        List {
            ForEach(viewModel.options) { group in
                Section {
                    ForEach(group.options) { item in
                        Item(title: item.title,
                             subtitle: viewModel.subtitle(for: item),
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
}

struct UserProfileViewPreview: PreviewProvider {
    static var previews: some View {
        UserProfileView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
