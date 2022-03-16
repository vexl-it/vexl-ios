//
//  RequestAccessFacebookContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 15/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class RequestAccessFacebookContactsViewModel: RequestAccessContactsViewModel {

    override var title: String {
        L.registerFacebookContactsTitle()
    }

    override var subtitle: String {
        L.registerPhoneContactsSubtitle()
    }

    override var importButton: String {
        L.registerContactsImportButton()
    }

    override var displaySkipButton: Bool {
        true
    }

    override var portraitColor: Color {
        Appearance.Colors.purple1
    }

    override var portraitTextColor: Color {
        Appearance.Colors.purple5
    }

    override func next() {
        switch current {
        case .initial:
            current = .accessConfirmed
        case .accessConfirmed:
            current = .completed
        case .completed, .requestAccess, .confirmRejection:
            current = .initial
        }
    }
}
