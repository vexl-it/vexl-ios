//
//  ChatView.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import SwiftUI

typealias ChatFilterOption = ChatFilterView.Option

struct ChatView: View {

    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(alignment: .leading) {
            header

            ChatFilterView(selectedOption: $viewModel.filter,
                           action: { option in
                viewModel.action.send(.selectFilter(option: option))
            })

            ScrollView {
                ChatItemView()
            }
        }
        .background(Color.black)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var header: some View {
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
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

struct ChatItemView: View {

    var body: some View {
        HStack {
            Image(R.image.marketplace.defaultAvatar.name)
                .resizable()
                .frame(size: Appearance.GridGuide.mediumIconSize)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

struct ChatViewPreview: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: .init())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .previewDevice("iPhone 11")
    }
}
