//
//  RegisterContactsView+ContactsListView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import SwiftUI

struct ImportContactListView: View {

    @ObservedObject var viewModel: ImportContactsViewModel

    private var alignment: Alignment {
        switch viewModel.currentState {
        case .loading, .empty:
            return .center
        case .content, .success:
            return .top
        }
    }

    var body: some View {
        VStack {
            switch viewModel.currentState {
            case .empty:
                Text(L.registerContactsImportEmpty())
                    .foregroundColor(Appearance.Colors.primaryText)
                    .textStyle(.h3)
            case .loading:
                EmptyView()
            case .content, .success:
                ImportContactSearchBar(searchText: $viewModel.searchText,
                                       searchActionTitle: viewModel.searchActionTitle,
                                       onAction: {
                    viewModel.action.send(.searchActionTapped)
                })
                .padding(Appearance.GridGuide.padding)

                ScrollView {
                    ForEach(viewModel.filteredItems) { item in
                        ImportContactItemView(item: item, onSelection: { isSelected in
                            viewModel.action.send(.itemSelected(isSelected, item))
                        })
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .background(Color.white)
        .cornerRadius(Appearance.GridGuide.padding)
    }
}

struct RegisterContacts_ContactListViewPreview: PreviewProvider {
    static var previews: some View {
        ImportContactListView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
