//
//  SegmentPicker.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

public struct CLSegmentedPicker<Item: Identifiable, Content: View>: View {
    private let activeSegmentColor: Color = Color(.tertiarySystemBackground)
    private let backgroundColor: Color = Color(.secondarySystemBackground)
    private let textColor: Color = Color(.secondaryLabel)
    private let selectedTextColor: Color = Color(.label)

    private let segmentCornerRadius: CGFloat = 100
    private let segmentXPadding: CGFloat = 16
    private let segmentYPadding: CGFloat = 8
    private let pickerPadding: CGFloat = 4

    private let animationDuration: Double = 0.1

    // Stores the size of a segment, used to create the active segment rect
    @State private var segmentSize = CGSize.zero

    // Rounded rectangle to denote active segment
    private var activeSegmentView: AnyView {

        // Don't show the active segment until we have initialized the view
        // This is required for `.animation()` to display properly, otherwise the animation will fire on init
        let isInitialized: Bool = segmentSize != .zero
        if !isInitialized { return EmptyView().asAnyView() }

        return RoundedRectangle(cornerRadius: segmentCornerRadius)
                .foregroundColor(activeSegmentColor)
                .withShadow()
                .frame(size: segmentSize)
                .offset(x: computeActiveSegmentHorizontalOffset(), y: 0)
                .animation(.linear(duration: animationDuration))
                .asAnyView()
    }

    private let items: [Item]
    @Binding private var selection: Item
    @ViewBuilder private let content: (Item) -> Content

    public init(items: [Item], selection: Binding<Item>, @ViewBuilder content: @escaping (Item) -> Content) {
        self._selection = selection
        self.items = items
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            activeSegmentView

            HStack {
                ForEach(items) { item in
                    let isSelected = selection.id == item.id

                    content(item)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(isSelected ? selectedTextColor : textColor)
                        .padding(.vertical, segmentYPadding)
                        .padding(.horizontal, segmentXPadding)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .readSize { if segmentSize != $0 { segmentSize = $0 } }
                        .onTapGesture { selection = item }
                }
            }
        }
        .padding(pickerPadding)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: segmentCornerRadius))
    }

    // Helper method to compute the offset based on the selected index
    private func computeActiveSegmentHorizontalOffset() -> CGFloat {
        CGFloat(items.firstIndex(where: { $0.id == selection.id })!) * (segmentSize.width + segmentXPadding / 2)
    }
}

