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
