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
            ImportContactListView(viewModel: viewModel)
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.vertical, Appearance.GridGuide.padding)

            LargeSolidButton(title: viewModel.actionTitle,
                             font: Appearance.TextStyle.h3.font.asFont,
                             style: .custom(color: viewModel.currentState == .success ? .success : .welcome),
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.action.send(.importContacts)
            })
                .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
        }
    }
}

struct RegisterContactsImportViewPreview: PreviewProvider {
    static var previews: some View {
        ImportContactsView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
