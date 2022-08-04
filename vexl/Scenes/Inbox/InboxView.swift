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
            content: { inboxContent },
            stickyHeader: {
                inboxHeader.padding(.bottom, Appearance.GridGuide.point)
            },
            expandedBitcoinGraph: { isExpanded in
                viewModel.isGraphExpanded = isExpanded
            }
        )
        .coordinateSpace(name: RefreshControlView.coordinateSpace)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var inboxContent: some View {
        RefreshContainer(topPadding: 40,
                         hideRefresh: viewModel.isGraphExpanded,
                         isRefreshing: $viewModel.isRefreshing) {
            VStack(alignment: .leading) {
                inboxHeader

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
            .background(Color.black)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }

    private var inboxHeader: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(L.chatMainTitle())
                    .textStyle(.h2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if viewModel.hasPendingRequests {
                    Button {
                        viewModel.action.send(.requestTap)
                    } label: {
                        Image(R.image.chat.request.name)
                            .frame(size: Appearance.GridGuide.iconSize)
                    }
                    .padding(Appearance.GridGuide.point)
                    .background(Appearance.Colors.gray1)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }
            .padding(.top, Appearance.GridGuide.mediumPadding2)
            .padding(.horizontal, Appearance.GridGuide.padding)

            InboxFilterView(selectedOption: $viewModel.filter,
                            action: { option in
                viewModel.action.send(.selectFilter(option: option))
            })
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
