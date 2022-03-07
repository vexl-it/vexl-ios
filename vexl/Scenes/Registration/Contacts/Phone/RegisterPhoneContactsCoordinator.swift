//
//  RegisterPhoneContactsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio

class RegisterPhoneContactsCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }
    
}
