//
//  PasswordValidationViewModel.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 11/11/20.
//

import Combine
import Foundation
import Cleevio

enum PasswordRule: RuleType, CaseIterable {
    case mustHaveEightOrMoreCharacters
    case mustHaveNumber
    case mustHaveUppercaseAndLowercase

    var title: String {
        switch self {
        case .mustHaveEightOrMoreCharacters:
            return "8 or more characters"
        case .mustHaveNumber:
            return "Numeric character (0-9)"
        case .mustHaveUppercaseAndLowercase:
            return "Uppercase and lowercase letter (A,z)"
        }
    }
}

public class PasswordValidationViewModel: ObservableObject {

    //MARK:- Input

    private(set) var buttonTap = PassthroughSubject<Void, Never>()
    @Published var password: String = ""

    //MARK:- Output

    @Published private(set) var rules: [Rule] = []
    @Published private(set) var isContinueDisabled = true
    @Published private(set) var isLoading = false
    @Published var showSuccess = false

    private var cancelBag = CancelBag()

    public init() {
        setupRules()
        setupBindings()
    }

    private func setupRules() {
        for passwordRule in PasswordRule.allCases {
            let rule = Rule(type: passwordRule, isCompleted: false)
            rules.append(rule)
        }
    }

    private func setupBindings() {
        let passwordChanged = $password
            .share()

        passwordChanged
            .compactMap { password in
                guard let uppercaseRegEx = try? NSRegularExpression(pattern: ".*[A-Z]+.*")
                      let lowercaseRegEx = try? NSRegularExpression(pattern: ".*[a-z]+.*") else {
                    return nil
                }
                let mustHaveEightOrMoreCharactersCompleted = password.count >= 1
                let mustHaveNumberCompleted = password.rangeOfCharacter(from: .decimalDigits) != nil

                let range = NSRange(location: 0, length: password.utf16.count)
                let uppercaseCompleted = uppercaseRegEx.firstMatch(in: password, options: [], range: range) != nil
                let lowercaseCompleted = lowercaseRegEx.firstMatch(in: password, options: [], range: range) != nil
                return [
                    Rule(type: .mustHaveEightOrMoreCharacters, isCompleted: mustHaveEightOrMoreCharactersCompleted),
                    Rule(type: .mustHaveNumber, isCompleted: mustHaveNumberCompleted),
                    Rule(type: .mustHaveUppercaseAndLowercase, isCompleted: uppercaseCompleted && lowercaseCompleted)
                ]
            }
            .assign(to: \.rules, on: self)
            .store(in: cancelBag)

        passwordChanged
            .map { [weak self] _ in
                guard let self = self else { return true }
                return self.rules.contains(where: { !$0.isCompleted })
            }
            .assign(to: \.isContinueDisabled, on: self)
            .store(in: cancelBag)

        buttonTap
            .sink { [weak self] _ in
                self?.isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.showSuccess = true
                    self?.isLoading = false
                }
            }
            .store(in: cancelBag)
    }
}
