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
            HStack(spacing: Appearance.GridGuide.padding) {
                avatarImage

                Text(viewModel.username)
                    .textStyle(.h1)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.vertical, Appearance.GridGuide.mediumPadding2)

            HLine(color: Color.white, height: 3)
                .padding(.horizontal, Appearance.GridGuide.point)

            profileItems
        }
        .navigationBarHidden(true)
        .background(Color.black)
        .cornerRadius(Appearance.GridGuide.padding,
                      corners: [.topLeft, .topRight])
    }

    private var avatarImage: some View {
        Image(data: viewModel.avatar, placeholder: R.image.onboarding.emptyAvatar.name)
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
                            .onTapGesture {
                                viewModel.send(action: .itemTap(option: item))
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor.clear
            UITableView.appearance().contentInset = Appearance.GridGuide.scrollContentInset
        }
        .padding(.horizontal, -Appearance.GridGuide.point)
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
