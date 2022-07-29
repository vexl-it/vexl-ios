//
//  Frame.swift
//  Pods
//
//  Created by Diego on 18/01/22.
//

import SwiftUI

public struct FrameSizeModifier: ViewModifier {
    let size: CGSize
    var alignment: Alignment

    public func body(content: Content) -> some View {
        content
            .frame(width: size.width, height: size.height, alignment: alignment)
    }
}

extension View {
    public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        modifier(FrameSizeModifier(size: size, alignment: alignment))
    }
}
