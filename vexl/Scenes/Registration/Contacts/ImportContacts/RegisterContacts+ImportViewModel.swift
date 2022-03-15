//
//  RegisterContacts+ImportViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

extension RegisterContactsViewModel {

    final class ImportContactViewModel: ObservableObject {

        // swiftlint:disable nesting

        enum ViewState {
            case empty
            case loading
            case content
            case success
        }

        @Published var current: ViewState = .empty
        @Published var items: [RegisterContactsViewModel.ContactItem] = []
        @Published var searchText = ""

        var hasSelectedItem = false

        var filteredItems: [RegisterContactsViewModel.ContactItem] {
            guard !searchText.isEmpty else { return items }
            return items.filter { $0.name.contains(searchText) }
        }

        func select(_ isSelected: Bool, item: RegisterContactsViewModel.ContactItem) {
            guard let selectedIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
            var newItem = items[selectedIndex]
            newItem.isSelected = isSelected
            items[selectedIndex] = newItem

            hasSelectedItem = items.contains(where: { $0.isSelected })
        }

        func unselectAllItems() {
            var newItems: [RegisterContactsViewModel.ContactItem] = []
            for item in items {
                var newItem = item
                newItem.isSelected = false
                newItems.append(newItem)
            }
            items = newItems
            hasSelectedItem = false
        }
    }
}
