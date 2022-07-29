//
//  TryPinCodeViewModel.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 2/7/21.
//

import Foundation
import Combine
import LocalAuthentication
import Cleevio

class TryPinCodeViewModel: ObservableObject {

    // MARK: - Input

    private(set) var keyTap = PassthroughSubject<Int, Never>()
    private(set) var deleteTap = PassthroughSubject<Void, Never>()

    // MARK: - Output

    @Published var state: PinState = .enter
    @Published var pin: [Int] = []
    @Published var pinMatched = false
    @Published var invalidAttempts = 0
    var maxDigits = 4
    var userHaveBiometricSupport: Bool { checkBiometricSupport() }
    var biometricImageName: String { getBiometricImageName() }

    var title: String {
        switch state {
        case .enter:
            return "Enter passcode"
        case .missmatch:
            return "Passcode missmatch"
        default:
            return ""
        }
    }

    // MARK: - Variables

    private var isPinCompleted: Bool { pin.count == maxDigits }
    private var savedPin = ""
    private let context = LAContext()
    private var cancelBag = CancelBag()

    init() {
        savedPin = UserDefaults.standard.string(forKey: "pincode") ?? ""
        setupBindings()
    }

    func getPinColoredCount() -> Int {
        return pin.count
    }

    func evaluateBiometric() {
        let reason = "Let the app use TouchID in order to access sensitive data"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.pinMatched = true
                } else {
                    self?.pin.removeAll()
                }
            }
        }
    }

    private func setupBindings() {
        keyTap
            .sink { [weak self] value in
                guard let self = self else { return }
                switch self.state {
                case .enter:
                    self.addNumberToPin(value)
                    if self.isPinCompleted {
                        self.checkPasscodeMatch()
                    }
                case .missmatch:
                    self.addNumberToPin(value)
                    self.state = .enter
                default:
                    break
                }
            }
            .store(in: cancelBag)

        deleteTap
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.pin.removeLast()
            }
            .store(in: cancelBag)
    }

    private func addNumberToPin(_ number: Int) {
        guard pin.count < maxDigits else { return }
        pin.append(number)
    }

    private func checkPasscodeMatch() {
        let enteredPin = pin.map { String($0) }.joined()
        if enteredPin == savedPin {
            pinMatched = true
        } else {
            invalidAttempts += 1
            state = .missmatch
            pin.removeAll()
        }
    }

    private func checkBiometricSupport() -> Bool {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    private func getBiometricImageName() -> String {
        switch context.biometryType {
        case .faceID:
            return "ic-faceid"
        case .touchID:
            return "ic-touchid"
        case .none:
            return ""
        @unknown default:
            assertionFailure("Support new cases")
            return ""
        }
    }
}
