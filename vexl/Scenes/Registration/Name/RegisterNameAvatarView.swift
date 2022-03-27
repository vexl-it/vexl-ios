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
        AlertContainerView(error: $viewModel.error) {
            LoadingContainerView(loading: viewModel.loading) {
                ContentView(viewModel: viewModel)
            }
        }
    }
}

extension RegisterNameAvatarView {

    private struct ContentView: View {
        @ObservedObject var viewModel: RegisterNameAvatarViewModel

        var body: some View {
            ZStack {
                VStack {
                    switch viewModel.currentState {
                    case .phoneVerified:
                        PhoneVerified()
                    case .usernameInput:
                        NameInputView(username: $viewModel.username)
                        Spacer()
                        actionButton {
                            viewModel.send(action: .setUsername)
                        }
                    case .avatarInput:
                        AvatarInputView(name: viewModel.username,
                                        avatar: viewModel.avatar,
                                        addAction: {
                            viewModel.send(action: .addAvatar)
                        },
                                        deleteAction: {
                            viewModel.send(action: .deleteAvatar)
                        })
                        Spacer()
                        actionButton {
                            viewModel.send(action: .createUser)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
        }

        @ViewBuilder private func actionButton(with action: @escaping () -> Void) -> some View {
            SolidButton(Text(L.continue()),
                        isEnabled: $viewModel.isActionEnabled,
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton) {
                action()
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
        }
    }
}

struct RegisterNameAvatarViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterNameAvatarView(viewModel: .init())
    }
}
