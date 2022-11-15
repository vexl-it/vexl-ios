//
//  InboxView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import SwiftUI
import Cleevio

typealias InboxFilterOption = InboxFilterView.Option

struct InboxView: View {

    @ObservedObject var viewModel: InboxViewModel

    var body: some View {

        VStack(spacing: 0) {
            BitcoinView(viewModel: viewModel.bitcoinViewModel)
            inboxHeader
                .background(Color.black)
                .cornerRadius(Appearance.GridGuide.buttonCorner, corners: [.topLeft, .topRight])
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            inboxContent
        }
        .coordinateSpace(name: RefreshControlView.coordinateSpace)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    @ViewBuilder private var inboxContent: some View {
        if viewModel.isMarketplaceLocked {
            inboxHeader
        } else {
            OffsetScrollView(
                offsetChanged: { offset in
                    if offset.y > Constants.pullToRefreshActivationOffset {
                        viewModel.isRefreshing = true
                    }
                },
                content: {
                    LazyVStack(spacing: 0) {
                        Rectangle()
                            .frame(height: Appearance.GridGuide.smallPadding)
                        ForEach(viewModel.inboxItems) { chatItem in
                            InboxItemView(data: chatItem)
                                .padding(.bottom, Appearance.GridGuide.mediumPadding1)
                                .onTapGesture {
                                    viewModel.action.send(.selectMessage(chat: chatItem.chat))
                                }
                        }
                        Rectangle()
                            .frame(height: Appearance.GridGuide.homeTabBarHeight)
                    }
                }
            )
        }
    }

    private var inboxHeader: some View {
        VStack(alignment: .leading) {
            ZStack {
                title
                if viewModel.isRefreshing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }

            if !viewModel.isMarketplaceLocked {
                InboxFilterView(selectedOption: $viewModel.filter,
                                action: { option in
                    viewModel.action.send(.selectFilter(option: option))
                })
            }
        }
    }

    private var title: some View {
        HStack(alignment: .center) {
            Text(L.chatMainTitle())
                .textStyle(.h2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.isMarketplaceLocked {
                Button {
                    viewModel.action.send(.requestTap)
                } label: {
                    Image(viewModel.requestImageName)
                        .frame(size: Appearance.GridGuide.iconSize)
                }
                .padding(Appearance.GridGuide.point)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
        }
        .padding(.top, Appearance.GridGuide.mediumPadding2)
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

struct InboxViewPreview: PreviewProvider {
    static var previews: some View {
        let viewModel = InboxViewModel(bitcoinViewModel: .init())
        viewModel.inboxItems = []
        return InboxView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
