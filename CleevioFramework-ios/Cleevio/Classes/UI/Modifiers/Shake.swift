//
//  Shake.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/11/21.
//

import SwiftUI

struct Shake: GeometryEffect {
    var movement: CGFloat = 15
    var shakes = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: movement * sin(animatableData * .pi * CGFloat(shakes)),
                y: 0
            )
        )
    }
}
