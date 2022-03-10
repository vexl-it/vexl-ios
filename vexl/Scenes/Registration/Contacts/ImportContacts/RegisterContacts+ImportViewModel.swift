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
    }
}
