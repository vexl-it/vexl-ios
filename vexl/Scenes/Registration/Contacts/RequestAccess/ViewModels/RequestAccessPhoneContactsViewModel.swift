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
        super.update(state: state)
    }

    override func next() {
        switch current {
        case .initial:
            current = .requestAccess
        case .requestAccess, .confirmRejection:
            current = .accessConfirmed
        case .accessConfirmed:
            current = .completed
        case .completed:
            current = .initial
        }
    }

    override func cancel() {
        switch current {
        case .initial, .confirmRejection, .accessConfirmed, .completed:
            current = .initial
        case .requestAccess:
            current = .confirmRejection
        }
    }

    private func updateAlert(for state: ViewState) {
        switch state {
        case .initial, .completed, .accessConfirmed:
            alert = nil
        case .requestAccess:
            alert = .request
        case .confirmRejection:
            alert = .reject
        }
    }
}
