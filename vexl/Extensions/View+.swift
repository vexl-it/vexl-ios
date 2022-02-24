//
//  View+.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(_ condition: Bool,
                                                                  if ifTransform: (Self) -> TrueContent,
                                                                  else elseTransform: (Self) -> FalseContent) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }

    @ViewBuilder func ifLet<V, Transform: View>(_ value: V?, transform: (Self, V) -> Transform) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    @ViewBuilder func ifLet<V, TrueContent: View, FalseContent: View>(_ value: V?,
                                                                      if ifTransform: (Self, V) -> TrueContent,
                                                                      else elseTransform: (Self) -> FalseContent) -> some View {
        if let value = value {
            ifTransform(self, value)
        } else {
            elseTransform(self)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(ClippedRoundedCorners(radius: radius, corners: corners))
    }
}
