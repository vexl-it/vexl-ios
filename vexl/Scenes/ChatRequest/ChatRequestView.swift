//
//  ChatRequestView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

struct ChatRequestView: View {

    @ObservedObject var viewModel: ChatRequestViewModel

    var body: some View {
        VStack {
            HeaderTitleView(title: L.chatRequestMainTitle("\(viewModel.offerRequests.count)"),
                            showSeparator: false) {
                viewModel.action.send(.dismissTap)
            }
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
            .padding(.top, Appearance.GridGuide.largePadding1)

            TabView {
                ForEach(viewModel.offerRequests) { request in
                    ChatRequestOfferView(data: request)
                        .padding(.horizontal, Appearance.GridGuide.padding)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#if DEVEL || DEBUG

struct ChatRequestViewPreview: PreviewProvider {
    static var previews: some View {
        ChatRequestView(viewModel: .init())
            .previewDevice("iPhone 11")
            .background(Color.black)
    }
}

#endif
