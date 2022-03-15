//
//  RegisterContactsView+ContactsListView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import SwiftUI

extension RegisterContactsView {

    struct ContactListView: View {

        @ObservedObject var viewModel: RegisterContactsViewModel.ImportContactViewModel

        var body: some View {
            VStack {
                if !viewModel.items.isEmpty {
                    RegisterContactsView.ContactSearchBar(searchText: $viewModel.searchText,
                                                          hasSelectedItem: viewModel.hasSelectedItem,
                                                          onAction: {
                        viewModel.action.send(.unselectAll)
                    })
                    .padding(Appearance.GridGuide.padding)

                    ForEach(viewModel.filteredItems) { item in
                        RegisterContactsView.ContactItemView(item: item, onSelection: { isSelected in
                            viewModel.action.send(.itemSelected(isSelected, item))
                        })
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .cornerRadius(Appearance.GridGuide.padding)
        }
    }
}

struct RegisterContacts_ContactListViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.ContactListView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
