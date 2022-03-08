//
//  RegisterContacts+PhoneViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio
import SwiftUI

extension RegisterContactsViewModel {

    class PhoneContactsViewModel: ObservableObject {

        // MARK: - View State

        enum ViewState {
            case intro
            case selection
            case success
        }

        // MARK: - View Bindings

        @Published var currentState: ViewState = .intro
    }

}
