//
//  View+.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(ClippedRoundedCorners(radius: radius, corners: corners))
    }
}
