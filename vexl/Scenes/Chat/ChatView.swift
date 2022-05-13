//
//  ChatView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import SwiftUI

struct ChatView: View {

    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
            Text("Chat will go here")
                .foregroundColor(.white)
        }
    }
}
