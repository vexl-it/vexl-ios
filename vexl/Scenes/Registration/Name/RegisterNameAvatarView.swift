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

            if viewModel.currentState == .phoneVerified {
                PhoneVerified()
            } else {
                if viewModel.currentState == .usernameInput {
                    NameInputView(username: $viewModel.username)
                } else {
                    AvatarInputView(name: viewModel.username,
                                    avatar: viewModel.avatar,
                                    addAction: {
                        viewModel.send(action: .addAvatar)
                    },
                                    deleteAction: {
                        viewModel.send(action: .deleteAvatar)
                    })
                }

                Spacer()

                SolidButton(Text(L.continue()),
                            isEnabled: $viewModel.isActionEnabled,
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: SolidButtonColor.welcome,
                            dimensions: SolidButtonDimension.largeButton) {
                    viewModel.send(action: .nextTap)
                }
                .padding(.horizontal, Appearance.GridGuide.padding)
            }

        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct RegisterNameAvatarViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView(viewModel: .init())
    }
}
