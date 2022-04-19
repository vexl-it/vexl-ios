//
//  CoinVariationHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Foundation
import Cleevio
import SwiftUI

struct CoinVariationHeaderView: View {

    var currencySymbol: String
    var amount: String

    var body: some View {
        HStack {
            Image(R.image.profile.graph.name)
                .padding(.leading, Appearance.GridGuide.padding)

            Spacer()

            HStack(alignment: .top) {
                Text(currencySymbol)
                    .foregroundColor(.white)
                    .padding(.top, Appearance.GridGuide.smallPadding)
                Text(amount)
                    .textStyle(.h2)
                    .foregroundColor(Color(R.color.green5.name))
            }
            .padding(.trailing, Appearance.GridGuide.mediumPadding1)
        }
        .frame(alignment: .top)
    }
}

struct ExpandableCoinVariationHeaderView: View {

    var currencySymbol: String
    var amount: String
    var onTap: () -> Void

    @State var isExpanded = false

    var body: some View {
        VStack {
            CoinVariationHeaderView(currencySymbol: currencySymbol,
                                    amount: amount)

            if isExpanded {
                graphView
                PeriodSelectorView()
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                isExpanded.toggle()
                onTap()
            }
        }
    }

    private var graphView: some View {
        VStack(alignment: .center) {
            Text("Graph should go there")
                .foregroundColor(.white)
        }
        .frame(height: 100)
    }
}

struct PeriodSelectorView: View {
    var body: some View {
        HStack {
            Group {
                Spacer()
                Text("1 day")
                Spacer()
                Text("1 day")
                Spacer()
                Text("1 day")
                Spacer()
            }
            Group {
                Text("1 day")
                Spacer()
                Text("1 day")
                Spacer()
                Text("1 day")
                Spacer()
            }
        }
        .frame(height: 25)
    }
}
