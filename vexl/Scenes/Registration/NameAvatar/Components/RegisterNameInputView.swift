//
//  RegisterNameAvatarView+NameInput.swift
//  vexl
//
//  Created by Diego Espinoza on 25/02/22.
//

import SwiftUI
import Combine
import Cleevio

struct RegisterNameInputView: View {

    @Binding var username: String

    var body: some View {
        RegistrationCardView(title: L.registerNameAvatarInputTitle(),
                             subtitle: L.registerNameAvatarInputSubtitle(),
                             subtitlePositionIsBottom: true,
                             iconName: R.image.onboarding.eye.name,
                             bottomPadding: Appearance.GridGuide.padding,
                             content: {
            nameInput
                .padding(.top, Appearance.GridGuide.point)
        })
    }

    private var nameInput: some View {
        PlaceholderTextField(placeholder: L.registerNameAvatarInputPlaceholder(),
                             text: $username)
            .padding()
            .background(Appearance.Colors.gray6)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .transaction { $0.disablesAnimations = true }
    }
}

struct RegisterNameInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameInputView(username: .constant("My_Username"))
    }
}
