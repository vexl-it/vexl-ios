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
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Chat")
                    .textStyle(.h1)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    print("tapped requested")
                } label: {
                    Image(R.image.chat.request.name)
                        .frame(size: Appearance.GridGuide.iconSize)
                }
                .padding(Appearance.GridGuide.point)
                .background(Appearance.Colors.gray1)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
            }
            .padding(.top, Appearance.GridGuide.mediumPadding2)
            .padding(.horizontal, Appearance.GridGuide.mediumPadding1)

            HLine(color: Appearance.Colors.whiteText,
                  height: 3)
                .padding(.horizontal, Appearance.GridGuide.point)

            Spacer()
        }
        .background(Color.black)
        .cornerRadius(12)
    }
}

struct ChatViewreview: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
