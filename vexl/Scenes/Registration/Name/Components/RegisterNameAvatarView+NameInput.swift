//
//  RegisterNameAvatarView+NameInput.swift
//  vexl
//
//  Created by Diego Espinoza on 25/02/22.
//

import SwiftUI
import Combine
import Cleevio

extension RegisterNameAvatarView {

    struct NameInputView: View {

        @Binding var username: String

        var body: some View {
            RegistrationCardView(title: L.registerNameAvatarInputTitle(),
                                 subtitle: L.registerNameAvatarInputSubtitle(),
                                 iconName: R.image.onboarding.eye.name,
                                 content: nameInput.padding(.top, Appearance.GridGuide.largePadding1))
                .padding(.all, Appearance.GridGuide.point)
        }

        private var nameInput: some View {
            BorderedTextField(placeholder: L.registerNameAvatarInputPlaceholder(),
                              textStyle: .paragraphMedium,
                              text: $username)
                .transaction { $0.disablesAnimations = true }
        }
    }
}

struct RegisterNameInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView.NameInputView(username: .constant("My_Username"))
    }
}
