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

                HLine(color: Appearance.Colors.gray1,
                      height: 2)

                timeline
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
                        .rotationEffect(viewModel.bitcoinIncreased ? .zero : .degrees(180))
                    Text(viewModel.bitcoinPercentageVariation)
                }
                .animation(.easeInOut, value: viewModel.timelineSelected)
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
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timeline: some View {
        HStack {
            ForEach(viewModel.timelineOptions) { option in
                Button(action: { viewModel.send(action: .timelineTap(option)) }, label: {
                    Text(option.title)
                        .foregroundColor(Appearance.Colors.whiteText)
                        .opacity(opacity(for: option))
                        .textStyle(.description)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                })
                .padding(Appearance.GridGuide.point)
                .background(backgroundColor(for: option))
                .cornerRadius(8)
            }
        }
    }

    private func opacity(for option: TimelineOption) -> CGFloat {
        viewModel.timelineSelected == option ? 1.0 : 0.15
    }

    private func backgroundColor(for option: TimelineOption) -> Color {
        viewModel.timelineSelected == option ?
        Color.white.opacity(0.15) : .clear
    }
}

#if DEBUG
struct BitcoinViewPreview: PreviewProvider {
    static var previews: some View {
        BitcoinView(viewModel: .init())
            .background(Color.black)
    }
}
#endif
