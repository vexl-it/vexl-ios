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

            HStack {
                if viewModel.showBackButton {
                    LargeSolidButton(title: L.generalBack(),
                                     font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                     style: .secondary,
                                     isFullWidth: true,
                                     isEnabled: .constant(true),
                                     action: {
                        viewModel.action.send(.dismiss)
                    })
                }

                if viewModel.showActionButton {
                    LargeSolidButton(title: viewModel.actionTitle,
                                     font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                     style: .main,
                                     isFullWidth: true,
                                     isEnabled: .constant(true),
                                     action: {
                        viewModel.action.send(.importContacts)
                    })
                }
            }
                .padding(.horizontal, Appearance.GridGuide.point)
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
