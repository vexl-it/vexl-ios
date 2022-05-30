//
//  BitcoinContainerView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import SwiftUI

protocol HasBitcoinViewModel {
    var bitcoinViewModel: BitcoinViewModel { get }
}

struct BitcoinContainerView<Content: View>: View {
    let hasBitcoinViewModel: HasBitcoinViewModel
    let content: Content

    var body: some View {
        VStack {
            BitcoinView(
                viewModel: hasBitcoinViewModel.bitcoinViewModel
            )

            content
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#if DEBUG
struct BitcoinContainerViewPreview: PreviewProvider {
    static var previews: some View {
        let bvm = BitcoinViewModel()
        return BitcoinContainerView(
            hasBitcoinViewModel: bvm,
            content: UserProfileView(
                viewModel: .init(bitcoinViewModel: bvm)
            )
        )
    }
}
#endif
