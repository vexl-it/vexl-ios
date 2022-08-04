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
    let hasFilters: Bool
    let hasOffers: Bool
    let mainAction: () -> Void

    var body: some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            ForEach(items, id: \.self) { item in
                FilterButton(title: item.title, type: item.type, hasFilters: hasFilters) {
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
        let hasFilters: Bool
        let action: () -> Void

        private var textStyle: Appearance.TextStyle {
            hasFilters ? .paragraphBold : .description
        }

        private var foregroundColor: Color {
            hasFilters ? Appearance.Colors.yellow100 : Appearance.Colors.gray3
        }

        private var backgroundColor: Color {
            hasFilters ? Appearance.Colors.yellow20 : Appearance.Colors.gray1
        }

        var body: some View {
            Button(action: action, label: {
                HStack {
                    Text(title)
                        .textStyle(textStyle)

                    if type == .filter {
                        Image(systemName: "chevron.down")
                    }
                }
            })
            .foregroundColor(foregroundColor)
            .padding(Appearance.GridGuide.point)
            .background(backgroundColor)
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
            hasFilters: true,
            hasOffers: true,
            mainAction: { }
        )
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
