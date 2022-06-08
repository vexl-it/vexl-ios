//
//  InboxView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import SwiftUI

typealias InboxFilterOption = InboxFilterView.Option

struct InboxView: View {

    @ObservedObject var viewModel: InboxViewModel

    var body: some View {
        VStack(spacing: .zero) {
            BitcoinView(viewModel: viewModel.bitcoinViewModel)

            inboxContent
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var inboxContent: some View {
        VStack(alignment: .leading) {
            header

            InboxFilterView(selectedOption: $viewModel.filter,
                            action: { option in
                viewModel.action.send(.selectFilter(option: option))
            })

            ScrollView {
                Group {
                    ForEach(viewModel.chatItems) { chatItem in
                        InboxItemView(data: chatItem)
                            .padding(.bottom, Appearance.GridGuide.mediumPadding1)
                            .onTapGesture {
                                viewModel.action.send(.selectMessage(id: chatItem.id.uuidString))
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

    private var header: some View {
        HStack(alignment: .center) {
            Text(L.chatMainTitle())
                .textStyle(.h1)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

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
        .padding(.top, Appearance.GridGuide.mediumPadding2)
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

struct InboxViewPreview: PreviewProvider {
    static var previews: some View {
        InboxView(viewModel: .init(bitcoinViewModel: .init()))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
