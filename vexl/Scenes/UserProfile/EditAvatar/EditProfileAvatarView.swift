//
//  EditProfileAvatarView.swift
//  vexl
//
//  Created by Diego Espinoza on 17/07/22.
//

import SwiftUI

struct EditProfileAvatarView: View {

    @ObservedObject var viewModel: EditProfileAvatarViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.padding) {
            HeaderTitleView(title: "Edit name",
                            showsSeparator: false,
                            dismissAction: {
                viewModel.action.send(.dismissTap)
            })

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
