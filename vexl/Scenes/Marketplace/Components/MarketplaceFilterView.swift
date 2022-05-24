//
//  BuySellFilterView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

typealias MarketplaceFilterData = MarketplaceFilterView.FilterData

struct MarketplaceFilterView: View {

    let items: [FilterData]
    let actionTitle: String
    let mainAction: () -> Void

    var body: some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            ForEach(items, id: \.self) { item in
                FilterButton(title: item.title) {
                    item.action?()
                }
            }

            Spacer()

            Button(action: mainAction, label: {
                Text(actionTitle)
                    .textStyle(.description)
            })
            .textStyle(.paragraphBold)
            .foregroundColor(Appearance.Colors.green5)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(Appearance.Colors.green1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.horizontal, Appearance.GridGuide.point)
    }
}

extension MarketplaceFilterView {

    struct FilterData: Hashable, Equatable {
        let title: String
        let action: (() -> Void)?

        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
        }

        static func == (lhs: MarketplaceFilterView.FilterData, rhs: MarketplaceFilterView.FilterData) -> Bool {
            lhs.title == rhs.title
        }
    }

    private struct FilterButton: View {
        var title: String
        var action: () -> Void

        var body: some View {
            Button(action: action, label: {
                Text(title)
                    .textStyle(.description)
            })
            .foregroundColor(Appearance.Colors.gray3)
            .padding(Appearance.GridGuide.point)
            .background(Appearance.Colors.gray1)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}

#if DEBUG || DEVEL
struct MarketplaceFilterViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceFilterView(
            items: [
                MarketplaceFilterView.FilterData(title: "Hello", action: nil)
            ],
            actionTitle: "Offer",
            mainAction: { }
        )
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
