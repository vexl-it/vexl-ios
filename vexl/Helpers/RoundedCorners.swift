//
//  RoundedCorners.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import SwiftUI

struct ClippedRoundedCorners: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
