//
//  UserValidation.swift
//  vexl
//
//  Created by Diego Espinoza on 31/03/22.
//

import Foundation

struct PhoneValidation {
    var phoneConfirmation: PhoneConfirmation?
    var codeValidation: CodeValidation?
}

struct UserSecurity {
    var keys: UserKeys?
    var signature: UserSignature?
    var challenge: ChallengeValidation?
}
