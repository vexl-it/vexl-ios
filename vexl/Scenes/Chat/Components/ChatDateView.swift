//
//  ChatDateView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatDateView: View {

    let date: Date
    let isInitial: Bool

    var body: some View {
        Text("\(Formatters.chatDateFormatter.string(from: date))\(isInitial ? L.chatMessageStarted() : "")")
            .textStyle(.descriptionSemiBold)
            .foregroundColor(Appearance.Colors.gray3)
    }
}
