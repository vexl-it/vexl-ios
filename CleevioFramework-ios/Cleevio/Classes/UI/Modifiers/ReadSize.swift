//
//  ReadSize.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

extension View {
    
    public func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { metrics in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: metrics.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}

    static var defaultValue: CGSize = .zero
}
