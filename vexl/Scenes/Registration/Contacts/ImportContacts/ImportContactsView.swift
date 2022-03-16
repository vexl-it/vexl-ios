//
//  RegisterContacts+ImportView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import SwiftUI
import Cleevio

struct ImportContactsView: View {

    @ObservedObject var viewModel: ImportContactsViewModel

    var body: some View {
        VStack(spacing: .zero) {

            contactList
            .padding(.horizontal, Appearance.GridGuide.point)
            .padding(.vertical, Appearance.GridGuide.padding)

            SolidButton(Text(L.registerContactsImportButton()),
                        isEnabled: $viewModel.hasSelectedItem,
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton) {
                viewModel.action.send(.completed)
            }
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
        }
    }

    private var contactList: some View {
        ContactListView(viewModel: viewModel)
    }
}

struct RegisterContactsImportViewPreview: PreviewProvider {
    static var previews: some View {
        ImportContactsView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
