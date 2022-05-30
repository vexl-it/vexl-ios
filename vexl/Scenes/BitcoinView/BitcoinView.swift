//
//  BitcoinView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import SwiftUI

struct BitcoinView: View {
    @ObservedObject var viewModel: BitcoinViewModel
    @State private var isExpanded = false

    var body: some View {
        VStack {
            header

            if isExpanded {
                bigGraph
            }
        }
        .padding(Appearance.GridGuide.padding)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }

    private var header: some View {
        HStack {
            if isExpanded {
                expandedInfo
            } else {
                smallGraph
            }

            price
        }
    }

    private var expandedInfo: some View {
        VStack {
            Group {
                Text("Bitcoin")
                    .foregroundColor(Appearance.Colors.whiteText)

                HStack {
                    Image(systemName: "triangle.fill")
                    Text("2.5% today")
                }
                .foregroundColor(Appearance.Colors.yellow100)
            }
            .textStyle(.descriptionSemiBold)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var price: some View {
        Text("31 241 czk")
            .textStyle(.h2)
            .foregroundColor(Appearance.Colors.yellow60)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    private var smallGraph: some View {
        Image(R.image.profile.graph.name)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bigGraph: some View {
        Image(R.image.profile.bigGraph.name)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
struct BitcoinViewPreview: PreviewProvider {
    static var previews: some View {
        BitcoinView(viewModel: .init())
    }
}
#endif
