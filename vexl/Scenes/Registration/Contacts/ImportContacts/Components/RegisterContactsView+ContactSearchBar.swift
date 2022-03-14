//
//  RegisterContactsView+ContactSearchBar.swift
//  vexl
//
//  Created by Diego Espinoza on 14/03/22.
//

import Foundation
import SwiftUI

extension RegisterContactsView {

    struct ContactSearchTextField: View {

        @Binding var searchText: String
        @State var isEditing = false

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

                if !searchText.isEmpty {
                    Button(L.registerContactsImportDeselect()) {
                        print("123")
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
        RegisterContactsView.ContactSearchTextField(searchText: .constant(""))
        RegisterContactsView.ContactSearchTextField(searchText: .constant("Hello"))
    }
}
