//
//  PhoneNumberViewModel.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 01.12.2020.
//

import Combine
import Foundation

extension PhoneNumber {
    class ViewModel: ObservableObject {

        //MARK:- Input

        private(set) var buttonTap = PassthroughSubject<Void, Never>()
        @Published var phoneNumber: String = ""

        let container: DIContainer

        init(container: DIContainer) {
            self.container = container
        }
    }
}
