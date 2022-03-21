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

final class ImportContactsViewModel: ObservableObject {

    // MARK: - View State

    enum ViewState {
        case empty
        case loading
        case content
        case success
    }

    // MARK: - Action Bindings

    enum UserAction {
        case itemSelected(Bool, ImportContactItem)
        case unselectAll
        case completed
    }

    let action: ActionSubject<UserAction> = .init()
    let completed: ActionSubject<Void> = .init()

    // MARK: - View Bindings

    @Published var current: ViewState = .loading
    @Published var items: [ImportContactItem] = []
    @Published var searchText = ""
    @Published var canImportContacts = false
    @Published var hasSelectedItem = false

    // MARK: - Variables

    var filteredItems: [ImportContactItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.contains(searchText) }
    }

    private let cancelBag: CancelBag = .init()

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
                case .completed:
                    owner.completed.send(())
                }
            }
            .store(in: cancelBag)
    }

    private func select(_ isSelected: Bool, item: ImportContactItem) {
        guard let selectedIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[selectedIndex].isSelected = isSelected
        hasSelectedItem = items.contains(where: { $0.isSelected })
    }

    private func unselectAllItems() {
        for index in items.indices {
            items[index].isSelected = false
        }
        hasSelectedItem = false
    }
}

struct ImportContactItem: Identifiable {
    var id: Int
    var name: String
    var phone: String
    var avatar: Data?
    var isSelected = false

    static func stub() -> [ImportContactItem] {
        [
            ImportContactItem(id: 1, name: "Diego Espinoza 1", phone: "999 944 222", avatar: nil),
            ImportContactItem(id: 2, name: "Diego Espinoza 2", phone: "929 944 222", avatar: nil),
            ImportContactItem(id: 3, name: "Diego Espinoza 3", phone: "969 944 222", avatar: nil),
            ImportContactItem(id: 4, name: "Diego Espinoza 4", phone: "969 944 222", avatar: nil),
            ImportContactItem(id: 5, name: "Diego Test 4", phone: "969 944 222", avatar: nil)
        ]
    }
}
