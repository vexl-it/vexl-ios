//
//  RegisterContactsView+ContactSearchBar.swift
//  vexl
//
//  Created by Diego Espinoza on 14/03/22.
//

import Foundation
import SwiftUI

extension RegisterContactsView {

    struct ContactSearchBar: View {

        @Binding var searchText: String
        var hasSelectedItem: Bool
        var onAction: () -> Void

        var body: some View {
            HStack(spacing: Appearance.GridGuide.point) {

                ZStack {
                    Rectangle()
                        .foregroundColor(Appearance.Colors.gray4)

                    HStack {
                        Image(systemName: "magnifyingglass")
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text(L.generalSearch())
                                    .foregroundColor(Appearance.Colors.gray2)
                            }

                            TextField("", text: $searchText)
                                .foregroundColor(Appearance.Colors.primaryText)
                        }
                    }
                    .foregroundColor(Appearance.Colors.gray2)
                    .padding(.horizontal, Appearance.GridGuide.point)
                }
                .frame(height: Appearance.GridGuide.baseHeight)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

                if hasSelectedItem {
                    Button(L.registerContactsImportDeselect()) {
                        onAction()
                    }
                    .textStyle(.paragraph)
                    .foregroundColor(Color.white)
                    .padding(Appearance.GridGuide.point)
                    .background(Appearance.Colors.primaryText)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }
        }
    }
}

struct RegisterContacts_ContactSearchBarPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.ContactSearchBar(searchText: .constant(""), hasSelectedItem: false, onAction: {})
        RegisterContactsView.ContactSearchBar(searchText: .constant("Hello"), hasSelectedItem: false, onAction: {})
    }
}
