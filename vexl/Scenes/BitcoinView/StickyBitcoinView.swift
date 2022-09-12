//
//  StickyBitcoinView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import SwiftUI

struct StickyBitcoinView<Content: View, Header: View>: View {
    let bitcoinViewModel: BitcoinViewModel
    let isMarketplaceLocked: Bool
    let content: () -> Content
    let stickyHeader: () -> Header
    let expandedBitcoinGraph: (Bool) -> Void
    let lockedSellAction: () -> Void
    let lockedBuyAction: () -> Void

    @State private var bitcoinSize: CGSize = .zero
    @State private var stickHeaderIsVisible = false
    @State private var scrollableContentSize: CGSize = .zero
    @State private var safeAreaCoverOpacity: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            OffsetScrollView(
                isMarketplaceLocked ? [] : .vertical,
                showsIndicators: false,
                offsetChanged: offsetChanged(to:),
                content: { scrollableContent }
            )
            .padding(.top, 1) // to make scroll view clipped content
            .edgesIgnoringSafeArea(.top)

            Rectangle()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .opacity(safeAreaCoverOpacity)
                .edgesIgnoringSafeArea(.top)

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
                    expandedBitcoinGraph(size.height > 100)
                })

            if isMarketplaceLocked {
                ZStack {
                    Image(R.image.marketplace.lockedMarketplace.name)
                        .resizable()
                        .blur(radius: 20)

                    VStack {
                        content()
                            .background(Color.black)
                            .cornerRadius(Appearance.GridGuide.buttonCorner,
                                          corners: [.topLeft, .topRight])

                        LockedScreenView(sellingAction: {
                            lockedSellAction()
                        },
                                         buyingAction: {
                            lockedBuyAction()
                        })
                            .frame(maxHeight: .infinity)
                    }
                }
            } else {
                content()
                    .background(Color.black)
                    .cornerRadius(Appearance.GridGuide.buttonCorner,
                                  corners: [.topLeft, .topRight])
            }
        }
        .padding(.top, UIScreen.topInset)
        .padding(.bottom, isMarketplaceLocked ? 0 : Appearance.GridGuide.homeTabBarHeight)
        .readSize { size in
            if scrollableContentSize == .zero {
                scrollableContentSize = size
            }
        }
    }

    private func offsetChanged(to offset: CGPoint) {
        if offset.y < 0 {
            let currentOffset = abs(offset.y)
            let headerIsVisible = currentOffset >= bitcoinSize.height + (UIScreen.main.focusedView?.safeAreaInsets.top ?? 0)
            if headerIsVisible != stickHeaderIsVisible {
                stickHeaderIsVisible = headerIsVisible
            }
            let opacity = currentOffset / (bitcoinSize.height + (UIScreen.main.focusedView?.safeAreaInsets.top ?? 0))
            safeAreaCoverOpacity = opacity.clamped(from: 0, to: 1)
        } else {
            safeAreaCoverOpacity = 0
            stickHeaderIsVisible = false
        }
    }
}

#if DEBUG
struct StickyBitcoinViewViewPreview: PreviewProvider {
    static var previews: some View {
        let bvm = BitcoinViewModel()
        return StickyBitcoinView(
            bitcoinViewModel: bvm,
            isMarketplaceLocked: false,
            content: {
                VStack {
                    Text("Some content")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                }
            },
            stickyHeader: { EmptyView() },
            expandedBitcoinGraph: { _ in },
            lockedSellAction: { },
            lockedBuyAction: { }
        )
        .background(Color.black.ignoresSafeArea())
        .previewDevice("iPhone 11")
    }
}
#endif
