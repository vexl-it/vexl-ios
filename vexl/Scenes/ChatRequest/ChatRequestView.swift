//
//  ChatRequestView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

struct ChatRequestView: View {

    @ObservedObject var viewModel: ChatRequestViewModel
    @State private var currentIndex: Int = 0

    private var pageControlBottomPadding: CGFloat {
        Appearance.GridGuide.largeButtonHeight + Appearance.GridGuide.padding
    }

    private var numberOfPages: Binding<Int> {
        Binding(
            get: { self.viewModel.offerRequests.count },
            set: { _ in }
        )
    }

    var body: some View {
        VStack {
            HeaderTitleView(title: L.chatRequestMainTitle("\(viewModel.offerRequests.count)"),
                            showsSeparator: false) {
                viewModel.action.send(.dismissTap)
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
            .padding(.top, Appearance.GridGuide.largePadding1)

            if viewModel.offerRequests.isEmpty {
                Spacer()
            } else {
                ZStack(alignment: .bottom) {
                    ContinuousPageControl(
                        numberOfPages: numberOfPages,
                        currentIndex: $currentIndex
                    )
                    .padding(.bottom, pageControlBottomPadding)

                    TabView(selection: $currentIndex) {
                        ForEach(viewModel.offerRequests.indices, id: \.self) { index in
                            ChatRequestOfferView(data: viewModel.offerRequests[index],
                                                 accept: { chat in
                                viewModel.action.send(.acceptTap(chat: chat))
                            },
                                                 decline: { chat in
                                viewModel.action.send(.rejectTap(chat: chat))
                            })
                            .padding(.horizontal, Appearance.GridGuide.padding)
                            .tag(index)
                        }
                    }
                    .animation(.easeInOut, value: viewModel.offerRequests)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
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
