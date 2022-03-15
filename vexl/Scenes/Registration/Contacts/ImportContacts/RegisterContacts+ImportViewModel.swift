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

        // MARK: - View State

        enum ViewState {
            case empty
            case loading
            case content
            case success
        }

        // MARK: - Action Bindings

        enum UserAction {
            case itemSelected(Bool, RegisterContactsViewModel.ContactItem)
            case unselectAll
        }

        let action: ActionSubject<UserAction> = .init()

        // MARK: - Variables

        @Published var current: ViewState = .empty
        @Published var items: [RegisterContactsViewModel.ContactItem] = []
        @Published var searchText = ""

        private let cancelBag: CancelBag = .init()

        var hasSelectedItem = false

        var filteredItems: [RegisterContactsViewModel.ContactItem] {
            guard !searchText.isEmpty else { return items }
            return items.filter { $0.name.contains(searchText) }
        }

        // MARK: - Init

        init() {
            action
                .withUnretained(self)
                .sink { owner, action in
                    switch action {
                    case let .itemSelected(isSelected, item):
                        owner.select(isSelected, item: item)
                    case .unselectAll:
                        owner.unselectAllItems()
                    }
                }
                .store(in: cancelBag)
        }

        private func select(_ isSelected: Bool, item: RegisterContactsViewModel.ContactItem) {
            guard let selectedIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
            var newItem = items[selectedIndex]
            newItem.isSelected = isSelected
            items[selectedIndex] = newItem

            hasSelectedItem = items.contains(where: { $0.isSelected })
        }

        private func unselectAllItems() {
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
