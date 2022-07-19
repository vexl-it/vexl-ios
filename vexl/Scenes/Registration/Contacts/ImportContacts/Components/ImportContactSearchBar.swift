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
                    .foregroundColor(Appearance.Colors.gray6)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Appearance.Colors.gray3)

                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text(L.generalSearch())
                                .foregroundColor(Appearance.Colors.gray3)
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
            .foregroundColor(Appearance.Colors.whiteText)
            .frame(height: Appearance.GridGuide.baseHeight)
            .padding(.horizontal, Appearance.GridGuide.padding)
            .background(Appearance.Colors.black1)
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
