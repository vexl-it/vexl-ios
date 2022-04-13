//
//  BuySellFeedDetailView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct BuySellFeedDetailView: View {

    var body: some View {
        VStack(spacing: 0) {
            DoubleDetailItem(firstTitle: "123", secondTitle: "345")

            Divider()
                .background(Appearance.Colors.gray4)
                .padding(.horizontal, Appearance.GridGuide.point)

            SingleDetailItem(title: "78800")
        }
        .makeCorneredBorder(color: Appearance.Colors.gray4, borderWidth: 1, cornerRadius: Appearance.GridGuide.buttonCorner)
    }
}

extension BuySellFeedDetailView {

    private struct SingleDetailItem: View {
        let title: String

        var body: some View {
            Text(title)
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray2)
                .padding(Appearance.GridGuide.point)
                .frame(height: 52)
        }
    }

    private struct DoubleDetailItem: View {
        let firstTitle: String
        let secondTitle: String

        var body: some View {
            HStack {
                Text(firstTitle)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray2)
                    .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: Appearance.GridGuide.mediumPadding2)
                    .background(Appearance.Colors.gray4)

                Text(secondTitle)
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray2)
                    .frame(maxWidth: .infinity)
            }
            .padding(Appearance.GridGuide.point)
            .frame(height: 52)
        }
    }
}

#if DEBUG || DEVEL
struct BuySellFeedDetailViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellFeedDetailView()
            .previewDevice("iPhone 11")
    }
}
#endif
