//
//  RegisterContactsView+ContactSearchBar.swift
//  vexl
//
//  Created by Diego Espinoza on 14/03/22.
//

import Foundation
import SwiftUI

struct ImportContactSearchBar: View {

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

            Button(L.registerContactsImportDeselect()) {
                onAction()
            }
            .textStyle(.paragraph)
            .foregroundColor(hasSelectedItem ? Color.white : Appearance.Colors.gray2)
            .frame(height: Appearance.GridGuide.baseHeight)
            .padding(.horizontal, Appearance.GridGuide.padding)
            .background(hasSelectedItem ? Appearance.Colors.primaryText : Appearance.Colors.gray4)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .disabled(!hasSelectedItem)
        }
        .frame(height: Appearance.GridGuide.baseHeight)
    }
}

struct RegisterContacts_ContactSearchBarPreview: PreviewProvider {
    static var previews: some View {
        ImportContactSearchBar(searchText: .constant(""), hasSelectedItem: true, onAction: {})
        ImportContactSearchBar(searchText: .constant(""), hasSelectedItem: false, onAction: {})
        ImportContactSearchBar(searchText: .constant("Hello"), hasSelectedItem: false, onAction: {})
    }
}
