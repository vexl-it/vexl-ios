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
            HStack {
                CloseButton {
                    
                }
                
                VStack {
                    Image(R.image.marketplace.defaultAvatar.name)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ChatMessageViewPreview: PreviewProvider {
    static var previews: some View {
        ChatMessageView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
