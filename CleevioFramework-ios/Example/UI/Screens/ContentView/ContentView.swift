//
//  ContentView.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private(set) var viewModel: ContentViewModel
    
    var body: some View {
        ComponentsList(viewModel: .init(container: viewModel.container,
                                        components: Component.mockedData))
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel(dependencies: .preview))
    }
}
#endif
