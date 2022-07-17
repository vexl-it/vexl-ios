//
//  EditProfileNameView.swift
//  vexl
//
//  Created by Diego Espinoza on 14/07/22.
//

import SwiftUI
import Combine

struct EditProfileNameView: View {

    @ObservedObject var viewModel: EditProfileNameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.padding) {
            HeaderTitleView(title: L.userProfileEditNameTitle(),
                            showsSeparator: false,
                            dismissAction: {
                viewModel.action.send(.dismissTap)
            })

            HStack {
                TextField("", text: $viewModel.currentName)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.whiteText)

                Button {
                    viewModel.currentName = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Appearance.Colors.gray2)
                }
            }
            .padding()
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)

            LargeSolidButton(title: L.userProfileEditNameAction(),
                             font: Appearance.TextStyle.paragraphBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.action.send(.updateName)
            })
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .padding(Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL

struct EditProfileNameViewPreview: PreviewProvider {
    static var previews: some View {
        EditProfileNameView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
