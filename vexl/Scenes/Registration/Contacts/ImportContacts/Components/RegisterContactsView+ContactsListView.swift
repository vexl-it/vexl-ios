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

        @State var searchText = ""

        let items: [RegisterContactsViewModel.ContactItem]
        var filteredItems: [RegisterContactsViewModel.ContactItem] {
            guard !searchText.isEmpty else { return items }
            return items.filter { $0.name.contains(searchText) }
        }

        var body: some View {
            VStack {
                if !items.isEmpty {
                    RegisterContactsView.ContactSearchTextField(searchText: $searchText)
                    .padding(Appearance.GridGuide.padding)

                    ForEach(filteredItems) { item in
                        RegisterContactsView.ContactItemView(item: item)
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
        RegisterContactsView.ContactListView(items: RegisterContactsViewModel.ContactItem.stub())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
