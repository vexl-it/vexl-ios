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
                Text(L.marketplaceCurrencyBitcoin())
                    .foregroundColor(Appearance.Colors.whiteText)

                HStack {
                    Image(systemName: "triangle.fill")
                    Text(L.marketplaceCurrencyVariation1day("2.5%"))
                }
                .foregroundColor(Appearance.Colors.yellow100)
            }
            .textStyle(.descriptionSemiBold)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder private var price: some View {
        if viewModel.isLoading {
            LoadingDotsView(
                dotCount: 3,
                dotDiameter: 10,
                color: Appearance.Colors.yellow100
            )
        } else {
            Text(viewModel.bitcoinWithCurrency)
                .textStyle(.h2)
                .foregroundColor(Appearance.Colors.yellow60)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
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
