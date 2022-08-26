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
        StickyBitcoinView(
            bitcoinViewModel: viewModel.bitcoinViewModel,
            isMarketplaceLocked: viewModel.isMarketplaceLocked,
            content: { inboxContent },
            stickyHeader: {
                inboxHeader.padding(.bottom, Appearance.GridGuide.point)
            },
            expandedBitcoinGraph: { isExpanded in
                viewModel.isGraphExpanded = isExpanded
            },
            lockedSellAction: {
                viewModel.action.send(.sellTap)
            },
            lockedBuyAction: {
                viewModel.action.send(.buyTap)
            }
        )
        .coordinateSpace(name: RefreshControlView.coordinateSpace)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    @ViewBuilder private var inboxContent: some View {
        if viewModel.isMarketplaceLocked {
            inboxHeader
        } else {
            RefreshContainer(topPadding: Appearance.GridGuide.refreshContainerPadding,
                             hideRefresh: viewModel.isGraphExpanded,
                             isRefreshing: $viewModel.isRefreshing) {
                VStack(alignment: .leading) {
                    inboxHeader
                    inboxList
                }
                .background(Color.black)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
        }
    }

    private var inboxList: some View {
        ScrollView {
            Group {
                ForEach(viewModel.inboxItems) { chatItem in
                    InboxItemView(data: chatItem)
                        .padding(.bottom, Appearance.GridGuide.mediumPadding1)
                        .onTapGesture {
                            viewModel.action.send(.selectMessage(chat: chatItem.chat))
                        }
                }
            }
            .padding(.top, Appearance.GridGuide.mediumPadding1)
            .padding(.bottom, Appearance.GridGuide.homeTabBarHeight)
        }
    }

    private var inboxHeader: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(L.chatMainTitle())
                    .textStyle(.h2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    viewModel.action.send(.requestTap)
                } label: {
                    Image(viewModel.requestImageName)
                        .frame(size: Appearance.GridGuide.iconSize)
                }
                .padding(Appearance.GridGuide.point)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
                .hidden()
            }
            .padding(.top, Appearance.GridGuide.mediumPadding2)
            .padding(.horizontal, Appearance.GridGuide.padding)

            if !viewModel.isMarketplaceLocked {
                InboxFilterView(selectedOption: $viewModel.filter,
                                action: { option in
                    viewModel.action.send(.selectFilter(option: option))
                })
            }
        }
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
