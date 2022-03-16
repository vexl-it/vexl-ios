//
//  RequestAccessPhoneContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 15/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class RequestAccessPhoneContactsViewModel: RequestAccessContactsViewModel {

    override var title: String {
        L.registerPhoneContactsTitle()
    }

    override var subtitle: String {
        L.registerPhoneContactsSubtitle()
    }

    override var importButton: String {
        L.registerContactsImportButton()
    }

    override var displaySkipButton: Bool {
        false
    }

    override func update(state: ViewState) {
        updateAlert(for: state)
        if state == .completed {
            action.send(.completed)
        }
    }

    override func next() {
        switch current {
        case .initial:
            current = .requestAccess
        case .requestAccess, .rejectAccess:
            current = .completed
        case .completed:
            current = .initial
        }
    }

    override func cancel() {
        switch current {
        case .initial, .rejectAccess, .completed:
            current = .initial
        case .requestAccess:
            current = .rejectAccess
        }
    }

    private func updateAlert(for state: ViewState) {
        switch state {
        case .initial, .completed:
            alert = nil
        case .requestAccess:
            alert = .request
        case .rejectAccess:
            alert = .reject
        }
    }
}
