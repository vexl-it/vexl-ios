//
//  BuySellFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct BuySellFilterView: View {

    let items: [FilterItem]
    let actionTitle: String
    let filterAction: (Int) -> Void
    let action: () -> Void

    var body: some View {
        HStack(spacing: Appearance.GridGuide.smallPadding) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                FilterButton(title: item.title) {
                    filterAction(index)
                }
            }

            Spacer()

            Button(actionTitle) {
                action()
            }
            .textStyle(.h3)
            .foregroundColor(Appearance.Colors.green5)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(Appearance.Colors.green1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.horizontal, Appearance.GridGuide.point)
    }
}

extension BuySellFilterView {

    struct FilterItem: Identifiable {
        let id: Int
        let title: String
    }

    private struct FilterButton: View {

        var title: String
        var action: () -> Void

        var body: some View {
            Button(title) {
                action()
            }
            .foregroundColor(Appearance.Colors.gray3)
            .padding(Appearance.GridGuide.point)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
struct BuySellFilterViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellFilterView(
            items: [
                BuySellFilterView.FilterItem(id: 1, title: "Hello")
            ],
            actionTitle: "Offer",
            filterAction: { _ in },
            action: { }
        )
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
