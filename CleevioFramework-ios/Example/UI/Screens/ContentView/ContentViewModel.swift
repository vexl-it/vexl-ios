//
//  ContentViewModel.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import Foundation

class ContentViewModel: ObservableObject {
    let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }
}
