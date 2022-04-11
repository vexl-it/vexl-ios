//
//  BuySellView+Segment.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import Cleevio
import SwiftUI

struct BuySellSegmentView: View {

    var body: some View {

        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            HStack {
                Button {
                    
                } label: {
                    Text("Buy")
                        .textStyle(.h1)
                        .foregroundColor(Appearance.Colors.gray1)
                }

                Button {
                    
                } label: {
                    Text("Sell")
                        .textStyle(.h1)
                }
            }
        }
    }
}

#if DEBUG || DEVEL
struct BuySellSegmentViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellSegmentView()
            .previewDevice("iPhone 11")
    }
}
#endif
