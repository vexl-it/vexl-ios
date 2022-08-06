//
//  GroupsView.swift
//  vexl
//
//  Created by Adam Salih on 01.08.2022.
//

import SwiftUI
import Cleevio

struct GroupsView: View {

    @ObservedObject var viewModel: GroupsViewModel

    var body: some View {
        VStack {
            HeaderTitleView(
                title: L.groupsTitle(),
                showsSeparator: false
            ) {
                viewModel.action.send(.dismissTap)
            }
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
            .padding(.top, Appearance.GridGuide.largePadding1)

            LargeSolidButton(
                title: "+ " + L.groupsJoinButton(),
                font: Appearance.TextStyle.paragraphSmallSemiBold.font.asFont,
                style: .secondary,
                isFullWidth: true,
                isEnabled: .constant(true),
                action: { viewModel.action.send(.joinGroupTap) }
            )

            ScrollView {
                VStack {
                    ForEach(viewModel.groups) { group in
                        GroupCell(group: group)
                    }
                }
            }
        }
        .padding([.horizontal], Appearance.GridGuide.padding)
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct GroupCell: View {
    var group: ManagedGroup

    var body: some View {
        Text("Cell")
    }
}

#if DEBUG || DEVEL

struct GroupsViewPreviews: PreviewProvider {

    static var viewModel: GroupsViewModel {
        let viewModel = GroupsViewModel()
        return viewModel
    }

    static var previews: some View {
        GroupsView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
