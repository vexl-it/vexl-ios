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
            HeaderTitleView(title: "Edit name",
                            showsSeparator: false,
                            dismissAction: {
                viewModel.action.send(.dismissTap)
            })

            Text("qwe123123")
                .textStyle(.description)
                .foregroundColor(Appearance.Colors.gray4)

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

            LargeSolidButton(title: L.continue(),
                             font: Appearance.TextStyle.paragraphBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                print("1234")
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
