//
//  BuySellView.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import SwiftUI
import Cleevio
import Combine

struct BuySellView: View {

    @ObservedObject var viewModel: BuySellViewModel

    var body: some View {
        VStack {
            CoinValueVariationHeader(currencySymbol: "$", amount: "1231.43")
            
            Spacer()
            
            Text("1234")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Appearance.Colors.green1.edgesIgnoringSafeArea(.all))
    }
}
