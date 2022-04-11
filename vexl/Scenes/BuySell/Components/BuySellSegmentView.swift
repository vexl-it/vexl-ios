//
//  BuySellView+Segment.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import Cleevio
import SwiftUI

struct BuySellSegmentView: View {

    enum Option {
        case buy, sell
    }

    @State var selectedIndex = Option.buy

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            HStack {
                Button {
                    selectedIndex = .buy
                } label: {
                    Text("Buy")
                        .textStyle(.h1)
                        .foregroundColor(selectedIndex == .buy ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)

                Button {
                    selectedIndex = .sell
                } label: {
                    Text("Sell")
                        .textStyle(.h1)
                        .foregroundColor(selectedIndex == .sell ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)

            }
        }
    }
}

#if DEBUG || DEVEL
struct BuySellSegmentViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellSegmentView()
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
