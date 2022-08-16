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

    private let headerHeight: Double = 56

    var body: some View {
        VStack(spacing: .zero) {
            BitcoinView(viewModel: viewModel.bitcoinViewModel)

            content
                .background(Color.black)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var content: some View {
        VStack(spacing: 0) {
            header

            profileItems
        }
    }

    private var header: some View {
        HStack {
            Button(
                action: { viewModel.action.send(.donate) },
                label: { Image(R.image.profile.donate.name) }
            )
            .frame(width: headerHeight, height: headerHeight)
            Spacer()
            Button(
                action: { viewModel.action.send(.joinVexl) },
                label: { Image(R.image.profile.qrCode.name) }
            )
            .frame(width: headerHeight, height: headerHeight)
        }
        .padding()
        .frame(height: headerHeight)
    }

    private var profile: some View {
        VStack(alignment: .center, spacing: Appearance.GridGuide.padding) {
            avatarImage

            Text(viewModel.username)
                .textStyle(.h2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.bottom, Appearance.GridGuide.padding)
    }

    private var avatarImage: some View {
        Image(data: viewModel.avatar, placeholder: R.image.onboarding.emptyAvatar.name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(size: Appearance.GridGuide.largeIconSize)
            .cornerRadius(Appearance.GridGuide.baseHeight * 0.5, corners: .allCorners)
    }

    @ViewBuilder private var profileItems: some View {
        ScrollView {
            VStack {
                profile

                ForEach(viewModel.options) { group in
                    VStack(spacing: .zero) {
                        ForEach(group.options) { item in
                            Item(title: item.title,
                                 subtitle: viewModel.subtitle(for: item),
                                 icon: item.iconName,
                                 isDestructive: item == .logout)
                                .background(Appearance.Colors.gray0)
                            .onTapGesture {
                                viewModel.send(action: .itemTap(option: item))
                            }

                            if item != group.options.last {
                                HLine(color: Appearance.Colors.gray1, height: 1)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
                    .padding(.vertical, Appearance.GridGuide.point)
                    .background(Appearance.Colors.gray0)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                    .padding(Appearance.GridGuide.point)
                }
            }
            .padding(.bottom, Appearance.GridGuide.scrollContentInset.bottom)
        }
    }
}

struct UserProfileViewPreview: PreviewProvider {
    static var previews: some View {
        UserProfileView(
            viewModel: UserProfileViewModel(
                bitcoinViewModel: .init()
            )
        )
            .previewDevice("iPhone 11")
    }
}
