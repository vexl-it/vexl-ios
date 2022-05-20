//
//  HLine.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import SwiftUI

struct DashedLine: View {

    let lineWidth: CGFloat

    init(lineWidth: CGFloat = 2) {
        self.lineWidth = lineWidth
    }

    var body: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: [8]))
    }

    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            }
         }
     }
}
