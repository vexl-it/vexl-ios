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
    let filterAction: (Int) -> Void
    let action: () -> Void

    var body: some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                FilterButton(title: item.title) {
                    filterAction(index)
                }
            }

            Spacer()

            Button {
                action()
            } label: {
                Image(systemName: "plus")
            }
            .textStyle(.paragraphBold)
            .foregroundColor(Appearance.Colors.yellow100)
            .padding(Appearance.GridGuide.point)
            .background(Appearance.Colors.yellow20)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.horizontal, Appearance.GridGuide.point)
    }
}

extension MarketplaceFilterView {

    struct FilterData: Identifiable {
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
struct MarketplaceFilterViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceFilterView(
            items: [
                MarketplaceFilterView.FilterData(id: 1, title: "Hello")
            ],
            filterAction: { _ in },
            action: { }
        )
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
