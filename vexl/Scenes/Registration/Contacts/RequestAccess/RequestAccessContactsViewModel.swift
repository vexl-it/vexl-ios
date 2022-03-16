//
//  RegisterContacts+PhoneViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class RequestAccessContactsViewModel: ObservableObject {

    enum AlertType: Int, Identifiable {
        case request = 1
        case reject = 2

        var id: Int {
            self.rawValue
        }

        var title: String {
            switch self {
            case .request:
                return L.registerPhoneAlertRequestTitle()
            case .reject:
                return L.registerPhoneAlertRejectTitle()
            }
        }

        var message: String {
            switch self {
            case .request:
                return L.registerPhoneAlertRequestDescription()
            case .reject:
                return L.registerPhoneAlertRejectDescription()
            }
        }
    }

    enum ViewState {
        case initial
        case requestAccess
        case rejectAccess
        case completed

        var next: ViewState {
            switch self {
            case .initial:
                return .requestAccess
            case .requestAccess, .rejectAccess:
                return .completed
            case .completed:
                return .initial
            }
        }

        var cancel: ViewState {
            switch self {
            case .initial, .rejectAccess, .completed:
                return .initial
            case .requestAccess:
                return .rejectAccess
            }
        }
    }

    @Published var current: ViewState = .initial {
        didSet {
            updateState()
        }
    }
    @Published var alert: AlertType?
    var onCompleted: ActionSubject<Void> = .init()

    var userName: String

    init(userName: String) {
        self.userName = userName
    }

    func next() {
        current = current.next
    }

    func cancel() {
        current = current.cancel
    }

    private func updateState() {
        updateAlert()
        if current == .completed {
            onCompleted.send()
        }
    }

    private func updateAlert() {
        switch current {
        case .initial, .completed:
            alert = nil
        case .requestAccess:
            alert = .request
        case .rejectAccess:
            alert = .reject
        }
    }
}
