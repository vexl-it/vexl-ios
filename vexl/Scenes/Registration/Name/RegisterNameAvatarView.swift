//
//  RegisterNameAvatarView.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

struct RegisterNameAvatarView: View {

    @ObservedObject var viewModel: RegisterNameAvatarViewModel

    var body: some View {
        VStack {
            RegistrationCardView(title: L.registerNameAvatarInputTitle(),
                                 subtitle: L.registerNameAvatarInputSubtitle(),
                                 content: nameInput.padding(.top, 40))

            Spacer()

            SolidButton(Text(L.continue()),
                        isEnabled: .constant(true),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton) {
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var nameInput: some View {
        BorderedTextField(placeholder: L.registerNameAvatarInputPlaceholder(),
                          text: .constant(""))
            .textStyle(.paragraph)
    }
}

struct RegisterNameAvatarViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView(viewModel: .init())
    }
}
