//
//  CoinView.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import SwiftUI

struct CoinView: View {

    @ObservedObject var viewModel: CoinViewModel

    var body: some View {
        ExpandableCoinVariationHeaderView(currencySymbol: "$",
                                          amount: "123123")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Appearance.Colors.green1
                            .edgesIgnoringSafeArea(.all))
    }
}
