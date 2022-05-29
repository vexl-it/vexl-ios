//
//  ChatMessageView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import SwiftUI

struct ChatMessageView: View {

    @ObservedObject var viewModel: ChatMessageViewModel

    var body: some View {
        VStack {
            Text("Message")
                .foregroundColor(Appearance.Colors.whiteText)
        }
        .background(Color.black)
    }
}
