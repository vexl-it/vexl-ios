//
//  PinCodeOptionsViewModel.swift
//  CleevioUIExample
//
//  Created by Daniel Fernandez on 2/7/21.
//

import Foundation
import Combine

extension PinCodeOptionsView {
    
    public class PinCodeOptionsViewModel: ObservableObject {

        // MARK: - Input

        private(set) var reload = PassthroughSubject<Void, Never>()

        // MARK: - Output

        @Published var pinDeleted = false
        @Published var isPinSaved = false

        // MARK: - Variables

        private var cancelBag = CancelBag()

        public init() {
            checkSavedPin()
            setupBindings()
        }

        func deleteSavedPin() {
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "pincode")
            pinDeleted = true
        }

        private func setupBindings() {
            reload
                .sink { [weak self] _ in
                    self?.checkSavedPin()
                }
                .store(in: cancelBag)
        }
        
        private func checkSavedPin() {
            let userDefaults = UserDefaults.standard
            isPinSaved = userDefaults.object(forKey: "pincode") != nil
        }
    }

}
