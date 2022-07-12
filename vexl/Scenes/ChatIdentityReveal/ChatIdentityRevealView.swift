//
//  ChatIdentityRevealView.swift
//  vexl
//
//  Created by Diego Espinoza on 7/07/22.
//

import SwiftUI

struct ChatIdentityRevealView: View {

    @ObservedObject var viewModel: ChatIdentityRevealViewModel

    var body: some View {
        VStack {
            VStack(spacing: .zero) {
                Text(L.chatMessageIdentityRevealApproved())
                    .textStyle(.paragraphBold)
                    .foregroundColor(Appearance.Colors.whiteText)
                    .padding(.bottom, Appearance.GridGuide.mediumPadding1)

                Image(data: viewModel.avatarData,
                      placeholder: R.image.marketplace.defaultAvatar.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.chatImageSize)
                    .cornerRadius(Appearance.GridGuide.requestCorner)
                    .padding(.bottom, Appearance.GridGuide.mediumPadding2)

                Text(viewModel.username)
                    .textStyle(.h2)
                    .foregroundColor(Appearance.Colors.whiteText)
            }
            .frame(maxHeight: .infinity)

            LargeSolidButton(title: L.continue(),
                             font: Appearance.TextStyle.paragraphBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.action.send(.dismissTap)
            })
                .padding(.horizontal, Appearance.GridGuide.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG || DEVEL

struct ChatIdentityRevealViewPreview: PreviewProvider {
    static var previews: some View {
        ChatIdentityRevealView(viewModel: .init(isUserResponse: true, username: "Username 1", avatar: nil))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
