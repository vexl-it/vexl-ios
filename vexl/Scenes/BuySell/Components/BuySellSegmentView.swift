//
//  BuySellView+Segment.swift
//  vexl
//
//  Created by Diego Espinoza on 11/04/22.
//

import Cleevio
import SwiftUI

struct BuySellSegmentView: View {

    enum Option {
        case buy, sell
    }

    @State var selectedOption = Option.buy

    var body: some View {
        VStack(spacing: Appearance.GridGuide.mediumPadding2) {
            HStack {
                Button {
                    selectedOption = .buy
                } label: {
                    Text(L.marketplaceBuy())
                        .textStyle(.h1)
                        .foregroundColor(selectedOption == .buy ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)

                Button {
                    selectedOption = .sell
                } label: {
                    Text(L.marketplaceSell())
                        .textStyle(.h1)
                        .foregroundColor(selectedOption == .sell ? Appearance.Colors.whiteText : Appearance.Colors.gray1)
                }
                .frame(maxWidth: .infinity)
            }

            //selectorView
            HLine()
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(Appearance.Colors.gray1)
                .frame(height: 3)
        }
        .overlay(
            GeometryReader { reader in
                Color.white
                    .frame(width: reader.size.width * 0.5, height: 3, alignment: .bottom)
            }
            .frame(height: 3, alignment: .bottom)
        )
//        .overlay(
//            VStack {
//                Spacer()
//
//                ZStack {
//                    HLine()
//                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
//                        .foregroundColor(Appearance.Colors.gray1)
//
//                    selectorView
//                }.frame(height: 3, alignment: .bottom)
//            }
//        )
    }

    @ViewBuilder var selectorView: some View {
        ZStack {
            HLine()
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(Appearance.Colors.gray1)

            GeometryReader { reader in
                Color.white
                    .frame(width: reader.size.width * 0.5, height: 3)
                    .offset(x: selectedOption == .buy ? 0 : reader.size.width * 0.5)
            }
        }.frame(height: 3, alignment: .bottom)
    }
}

struct HLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

#if DEBUG || DEVEL
struct BuySellSegmentViewPreview: PreviewProvider {
    static var previews: some View {
        BuySellSegmentView(selectedOption: .sell)
            .background(Color.black)
            .previewDevice("iPhone 11")
    }
}
#endif
