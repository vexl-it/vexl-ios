//
//  ComponentsListViewModel.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import Foundation

class ComponentsListViewModel: ObservableObject {

    // MARK: - State

    @Published var components: [Component]

    // MARK: - Misc

    let container: DIContainer
    private var cancelBag = CancelBag()

    init(container: DIContainer, components: [Component]) {
        self.container = container
        self.components = components
    }
}
