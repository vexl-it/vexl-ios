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
    let hasOffers: Bool
    let mainAction: () -> Void

    var body: some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            ForEach(items, id: \.self) { item in
                FilterButton(title: item.title, type: item.type) {
                    item.action?()
                }
            }

            Spacer()

            Button(action: mainAction, label: {
                if hasOffers {
                    Text(L.marketplaceSellOffer())
                        .textStyle(.paragraphSmallBold)
                } else {
                    Image(systemName: "plus")
                        .frame(size: Appearance.GridGuide.iconSize)
                }
            })
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
    enum LabelType {
        case label
        case filter
    }

    struct FilterData: Hashable, Equatable {
        let id = UUID()
        let title: String
        let type: LabelType
        let action: (() -> Void)?

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: MarketplaceFilterView.FilterData, rhs: MarketplaceFilterView.FilterData) -> Bool {
            lhs.id == rhs.id
        }
    }

    private struct FilterButton: View {
        let title: String
        let type: LabelType
        let action: () -> Void

        var body: some View {
            Button(action: action, label: {
                HStack {
                    Text(title)
                        .textStyle(.description)

                    if type == .filter {
                        Image(systemName: "chevron.down")
                    }
                }
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
                MarketplaceFilterView.FilterData(
                    title: "Filters",
                    type: .label,
                    action: nil
                )
            ],
            hasOffers: true,
            mainAction: { }
        )
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
