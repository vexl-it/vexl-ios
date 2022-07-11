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
        VStack(alignment: .trailing) {
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
        ChatIdentityRevealView(viewModel: .init(isUserResponse: true))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}

#endif
