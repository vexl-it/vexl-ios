//
//  OffsetScrollView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import SwiftUI

struct OffsetScrollView<Content: View>: View {
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let offsetChanged: (CGPoint) -> Void
    @ViewBuilder private let content: () -> Content

    init(_ axes: Axis.Set = .vertical,
         showsIndicators: Bool = true,
         offsetChanged: @escaping (CGPoint) -> Void = { _ in },
         @ViewBuilder content: @escaping () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content
    }

    var body: some View {
        SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).origin
                    )
                }.frame(width: 0, height: 0)
                content()
            }
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}
