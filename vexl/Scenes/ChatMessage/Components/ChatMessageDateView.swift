//
//  ChatMessageDateView.swift
//  vexl
//
//  Created by Diego Espinoza on 30/05/22.
//

import SwiftUI

struct ChatMessageDateView: View {

    let date: Date
    let isInitial: Bool

    var body: some View {
        Text("Date goes here\(isInitial ? " • Chat has started" : "")")
            .textStyle(.descriptionSemiBold)
            .foregroundColor(Appearance.Colors.gray3)
    }
}
