//
//  HLine.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import SwiftUI

struct HLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
     }
 }
