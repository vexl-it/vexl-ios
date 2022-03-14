//
//  RegisterContacts+ImportView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import SwiftUI
import Cleevio

extension RegisterContactsView {

    struct ImportContactsView: View {

        @ObservedObject var viewModel: RegisterContactsViewModel.ImportContactViewModel

        var body: some View {
            VStack(spacing: .zero) {

                contactList
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.vertical, Appearance.GridGuide.padding)

                SolidButton(Text(L.registerContactsImportButton()),
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: SolidButtonColor.welcome,
                            dimensions: SolidButtonDimension.largeButton) {
                    print("1234")
                }
                .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
            }
        }

        private var contactList: some View {
            RegisterContactsView.ContactListView(items: viewModel.items)
        }
    }
}

struct RegisterContactsImportViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterContactsView.ImportContactsView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
