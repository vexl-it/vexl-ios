//
//  BitcoinView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import SwiftUI
import SwiftUICharts

struct BitcoinView: View {
    @ObservedObject var viewModel: BitcoinViewModel

    private let headerHeight: Double = 38
    private let expandedInfoHeight: Double = 342
    private let chartBigHeight: Double = 150
    private let chartSmallHeight: Double = 130
    private let backgroundGradientPaddingTop: Double = -44
    private let backgroundGradientPaddingBottom: Double = -20

    private var chartData: LineChartData {
        LineChartData(
            dataSets: LineDataSet(
                dataPoints: viewModel.chartDataPoints,
                style: LineStyle(
                    lineColour: ColourStyle(
                        colours: [.clear, Appearance.Colors.yellow60],
                        startPoint: UnitPoint(x: 0, y: 1),
                        endPoint: UnitPoint(x: 0, y: 0)
                    ),
                    lineType: .curvedLine,
                    ignoreZero: true
                )
            ),
            chartStyle: LineChartStyle(
                globalAnimation: .linear(duration: 0)
            )
        )
    }

    var body: some View {
        VStack {
            header

            if viewModel.isExpanded {
                bigGraph

                timeline

                HLine(color: Appearance.Colors.whiteText.opacity(0.1),
                      height: 2)

                timelineOptions
            }
        }
        .padding(Appearance.GridGuide.padding)
        .background(gradientBackground)
        .onTapGesture {
            withAnimation {
                viewModel.action.send(.toggleExpand)
            }
        }
    }

    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                Gradient.Stop(color: .clear, location: 0),
                Gradient.Stop(color: Appearance.Colors.yellow40, location: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .padding(.top, backgroundGradientPaddingTop)
        .padding(.bottom, backgroundGradientPaddingBottom)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: Appearance.GridGuide.mediumPadding2) {
            if viewModel.isExpanded {
                expandedInfo
            } else {
                smallGraph
            }
            Spacer()
            price
        }
        .frame(height: headerHeight)
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
        .frame(height: expandedInfoHeight)
    }

    @ViewBuilder private var price: some View {
        if viewModel.isLoadingCoinData {
            LoadingDotsView(
                dotCount: 3,
                dotDiameter: 10,
                color: Appearance.Colors.yellow100
            )
        } else {
            HStack(alignment: .top) {
                if viewModel.currency.position == .left {
                    Text(viewModel.currency.sign)
                        .textStyle(.micro)
                        .foregroundColor(viewModel.isExpanded ? Appearance.Colors.yellow100 : Appearance.Colors.yellow60)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.top, Appearance.GridGuide.tinyPadding)
                }
                Text(viewModel.bitcoinValue)
                    .textStyle(.h2)
                    .foregroundColor(viewModel.isExpanded ? Appearance.Colors.yellow100 : Appearance.Colors.yellow60)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(maxHeight: .infinity)

                if viewModel.currency.position == .right {
                    Text(viewModel.currency.sign)
                        .textStyle(.micro)
                        .foregroundColor(viewModel.isExpanded ? Appearance.Colors.yellow100 : Appearance.Colors.yellow60)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.top, Appearance.GridGuide.tinyPadding)
                }
            }
        }
    }

    @ViewBuilder private var smallGraph: some View {
        if viewModel.isLoadingChartData {
            LoadingDotsView(
                dotCount: 3,
                dotDiameter: 10,
                color: Appearance.Colors.yellow100
                )
        } else {
            FilledLineChart(chartData: chartData)
                .filledTopLine(
                    chartData: chartData,
                    lineColour: ColourStyle(colour: Appearance.Colors.yellow60),
                    strokeStyle: StrokeStyle(lineWidth: 2)
                )
        }
    }

    @ViewBuilder private var bigGraph: some View {
        if viewModel.isLoadingChartData {
            LoadingDotsView(
                dotCount: 3,
                dotDiameter: 10,
                color: Appearance.Colors.yellow100
            )
            .frame(height: chartBigHeight)
        } else {
            FilledLineChart(chartData: chartData)
                .filledTopLine(
                    chartData: chartData,
                    lineColour: ColourStyle(colour: Appearance.Colors.yellow100),
                    strokeStyle: StrokeStyle(lineWidth: 2)
                )
                .frame(height: chartBigHeight)
                .padding(.horizontal, Appearance.GridGuide.padding)
                .allowsHitTesting(false)
        }
    }

    private var timeline: some View {
        HStack {
            ForEach(viewModel.timelineSelected.timeline) { timeline in
                Text(timeline)
                    .foregroundColor(Appearance.Colors.whiteText)
                    .opacity(0.5)
                    .textStyle(.description)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var timelineOptions: some View {
        HStack {
            ForEach(viewModel.timelineOptions) { option in
                Button(
                    action: {
                        viewModel.send(action: .timelineTap(option))
                    },
                    label: {
                        Text(option.title)
                            .foregroundColor(Appearance.Colors.whiteText)
                            .opacity(opacity(for: option))
                            .textStyle(.description)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                )
                .padding(Appearance.GridGuide.point)
                .background(backgroundColor(for: option))
                .cornerRadius(8)
            }
        }
    }

    private func opacity(for option: TimelineOption) -> CGFloat {
        viewModel.timelineSelected == option ? 1.0 : 0.5
    }

    private func backgroundColor(for option: TimelineOption) -> Color {
        viewModel.timelineSelected == option ?
        Color.white.opacity(0.15) : .clear
    }
}

#if DEBUG
struct BitcoinViewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            BitcoinView(viewModel: .init())
                .background(Color.black)
                .previewDevice("iPhone 11")
            Spacer()
        }.background(Color.black)
    }
}
#endif
