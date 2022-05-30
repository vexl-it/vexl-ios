//
//  HomeView.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.05.2022.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            BitcoinView()

//            MarketplaceView(viewModel: .init())
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

#if DEBUG
struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init())
    }
}
#endif
