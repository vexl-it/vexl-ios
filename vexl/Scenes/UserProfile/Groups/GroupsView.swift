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

            ScrollView {
                HStack {
#if DEVEL || DEBUG
                    LargeSolidButton(
                        title: "Create group",
                        font: Appearance.TextStyle.paragraphSmallSemiBold.font.asFont,
                        style: .secondary,
                        isFullWidth: true,
                        isEnabled: .constant(true),
                        action: { viewModel.action.send(.createGroupTap) }
                    )
#endif
                    LargeSolidButton(
                        title: "+ " + L.groupsJoinButton(),
                        font: Appearance.TextStyle.paragraphSmallSemiBold.font.asFont,
                        style: .secondary,
                        isFullWidth: true,
                        isEnabled: .constant(true),
                        action: { viewModel.action.send(.joinGroupTap) }
                    )
                }
                .padding(.bottom, Appearance.GridGuide.mediumPadding2)

                VStack {
                    ForEach(viewModel.groupViewModels) { viewModel in
                        GroupCell(viewModel: viewModel)
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
    @ObservedObject var viewModel: GroupCellViewModel

    var body: some View {
        HStack(alignment: .center) {
            Group {
                if let image = viewModel.logoImage {
                    image
                } else {
                    EmptyGroupLogoSmall(name: $viewModel.name)
                }
            }
            .frame(width: Appearance.GridGuide.mediumIconSize.width, height: Appearance.GridGuide.mediumIconSize.height)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.name)
                    .textStyle(Appearance.TextStyle.paragraphSemibold)
                    .foregroundColor(Appearance.Colors.whiteText)
                HStack {
                    Image(R.image.member.name)
                    Text(L.groupsItemMembers("\(viewModel.memberCount)"))
                        .textStyle(Appearance.TextStyle.paragraphSmall)
                        .foregroundColor(Appearance.Colors.whiteText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(
                action: {
                    viewModel.action.send(.leaveGroupTap(group: viewModel.group))
                },
                label: {
                    Text(L.groupsLeaveButton())
                        .foregroundColor(Appearance.Colors.gray4)
                }
            )
            .frame(width: 64, height: 40)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

struct EmptyGroupLogoSmall: View {
    @Binding var name: String

    var body: some View {
        ZStack {
            Appearance.Colors.gray1
            if let char = name.first, let strChar = String(char) {
                Text(strChar)
                    .textStyle(Appearance.TextStyle.h3)
                    .foregroundColor(Appearance.Colors.whiteText)
                    .opacity(0.1)
            }
        }
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

final class GroupCellViewModel: ObservableObject, Identifiable {
    let group: ManagedGroup

    let id: String

    @Published var logoImage: Image?
    @Published var name: String
    @Published var memberCount: Int

    var action: ActionSubject<GroupsViewModel.ActionType>

    init(group: ManagedGroup, action: ActionSubject<GroupsViewModel.ActionType>) {
        self.group = group
        self.action = action
        self.id = group.uuid ?? UUID().uuidString
        self.name = group.name ?? ""
        self.memberCount = group.members?.count ?? 0

        group
            .publisher(for: \.logo)
            .filterNil()
            .compactMap(UIImage.init)
            .map(Image.init)
            .assign(to: &$logoImage)

        group
            .publisher(for: \.name)
            .filterNil()
        #if DEVEL || DEBUG
            .map { $0 + " (\(Int(group.code)))" }
        #endif
            .assign(to: &$name)

        group
            .publisher(for: \.members)
            .filterNil()
            .map(\.count)
            .assign(to: &$memberCount)
    }
}

#if DEBUG || DEVEL

struct GroupsViewPreviews: PreviewProvider {

    static var viewModel: GroupsViewModel {
        let viewModel = GroupsViewModel()
        return viewModel
    }

    static var previews: some View {
        GroupCell(viewModel: .init(group: ManagedGroup(), action: .init()))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
            .background(Color.black.ignoresSafeArea())
    }
}

#endif
