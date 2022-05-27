//
//  Line.swift
//  vexl
//
//  Created by Diego Espinoza on 19/05/22.
//

import SwiftUI

struct HLine: View {

    let color: Color
    let height: CGFloat

    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .frame(height: height)
    }
}

struct VLine: View {

    let color: Color
    let width: CGFloat

    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .frame(width: width)
    }
}
