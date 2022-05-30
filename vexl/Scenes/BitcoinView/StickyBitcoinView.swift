//
//  StickyBitcoinView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import SwiftUI

struct StickyBitcoinView<Content: View, Header: View>: View {
    let bitcoinViewModel: BitcoinViewModel
    let content: () -> Content
    let stickyHeader: () -> Header

    @State private var bitcoinSize: CGSize = .zero
    @State private var stickHeaderIsVisible = false

    var body: some View {
        ZStack(alignment: .top) {
            OffsetScrollView(
                showsIndicators: false,
                offsetChanged: offsetChanged(to:),
                content: { scrollableContent }
            )
            .padding(.top, 1) // to make scroll view clipped content

            if stickHeaderIsVisible {
                stickyHeader()
                    .background(Color.black)
            }
        }
    }

    private var scrollableContent: some View {
        VStack(spacing: .zero) {
            BitcoinView(viewModel: bitcoinViewModel)
                .readSize(onChange: { size in
                    bitcoinSize = size
                })

            content()
                .background(Color.black)
                .cornerRadius(Appearance.GridGuide.buttonCorner,
                              corners: [.topLeft, .topRight])
        }
        .padding(.bottom, Appearance.GridGuide.homeTabBarHeight)
    }

    private func offsetChanged(to offset: CGPoint) {
        // TODO: improve this logic
        if offset.y < 0 {
            let currentOffset = abs(offset.y)
            stickHeaderIsVisible = currentOffset >= bitcoinSize.height
        }
    }
}

#if DEBUG
struct StickyBitcoinViewViewPreview: PreviewProvider {
    static var previews: some View {
        let bvm = BitcoinViewModel()
        return StickyBitcoinView(
            bitcoinViewModel: bvm) {
                UserProfileView(viewModel: .init(bitcoinViewModel: bvm))
            } stickyHeader: {
                EmptyView()
            }
    }
}
#endif
