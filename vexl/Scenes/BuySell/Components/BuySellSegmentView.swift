//
//  BuySellView+Segment.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import Cleevio
import SwiftUI

struct BuySellSegmentView: View {

    @State var selectedIndex = 0
    
    var body: some View {

        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            HStack {
                Button {
                    
                } label: {
                    Text("Buy")
                        .textStyle(.h1)
                        .foregroundColor(selectedIndex == 0 ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }

                Button {
                    
                } label: {
                    Text("Sell")
                        .textStyle(.h1)
                        .foregroundColor(selectedIndex == 1 ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
            }
        }
    }
}

#if DEBUG || DEVEL
struct BuySellSegmentViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellSegmentView()
            .frame(width: .infinity, height: .infinity)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
