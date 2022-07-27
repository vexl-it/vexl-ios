//
//  CreatePinCodeViewModel.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 1/11/21.
//

import Foundation
import Combine
import Cleevio

public class CreatePinCodeViewModel: ObservableObject {

    // MARK: - Input

    private(set) var keyTap = PassthroughSubject<Int, Never>()
    private(set) var deleteTap = PassthroughSubject<Void, Never>()

    // MARK: - Output

    @Published var state: PinState = .create
    @Published var pin: [Int] = []
    @Published var pinCreatedWithSuccess = false
    @Published var invalidAttempts = 0
    var maxDigits = 4

    var title: String {
        switch state {
        case .create:
            return "Create your passcode"
        case .confirm:
            return "Repeat your passcode"
        case .enter:
            return ""
        case .missmatch:
            return "Passcode missmatch"
        }
    }

    // MARK: - Dependencies

    private let reloadOptionsView: PassthroughSubject<Void, Never>
    
    // MARK: - Variables

    private var isPinCompleted: Bool { pin.count == maxDigits }
    private var initialPin: String = ""
    private var cancelBag = CancelBag()

    public init(reloadOptionsView: PassthroughSubject<Void, Never>) {
        self.reloadOptionsView = reloadOptionsView
        setupBindings()
    }

    func getPinColoredCount() -> Int {
        return pin.count
    }

    private func setupBindings() {
        keyTap
            .sink { [weak self] value in
                guard let self = self else { return }
                switch self.state {
                case .create:
                    self.addNumberToPin(value)
                    if self.isPinCompleted {
                        self.setInitialPasscode()
                    }
                case .confirm:
                    self.addNumberToPin(value)
                    if self.isPinCompleted {
                        self.checkPasscodeMatch()
                    }
                case .missmatch:
                    self.addNumberToPin(value)
                    self.state = .create
                case .enter:
                    break
                }
            }
            .store(in: cancelBag)

        deleteTap
            .sink { [weak self] _ in
                guard let self = self, !self.pin.isEmpty else { return }
                self.pin.removeLast()
            }
            .store(in: cancelBag)
    }

    private func addNumberToPin(_ number: Int) {
        guard pin.count < maxDigits else { return }
        pin.append(number)
    }

    private func setInitialPasscode() {
        initialPin = pin.map { String($0) }.joined()
        state = .confirm
        pin.removeAll()
    }

    private func checkPasscodeMatch() {
        let confirmedPin = pin.map { String($0) }.joined()
        if confirmedPin == initialPin {
            savePasscodeInKeychain()
        } else {
            invalidAttempts += 1
            state = .missmatch
            pin.removeAll()
            initialPin = ""
        }
    }

    private func savePasscodeInKeychain() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(initialPin, forKey: "pincode")
        pinCreatedWithSuccess = true
        reloadOptionsView.send(())
    }
}
