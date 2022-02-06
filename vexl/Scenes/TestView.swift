//
//  TestView.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import SwiftUI
import Combine

struct TestView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Text(viewModel.title)
    }
}

extension TestView {
    class ViewModel: ObservableObject {
        @Published var title: String = "Hello World"
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(viewModel: .init())
    }
}
