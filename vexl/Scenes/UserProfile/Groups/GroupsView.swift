//
//  GroupsView.swift
//  vexl
//
//  Created by Adam Salih on 01.08.2022.
//

import SwiftUI

struct GroupsView: View {

    @ObservedObject var viewModel: GroupsViewModel

    var body: some View {
        Text("Groups")
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
