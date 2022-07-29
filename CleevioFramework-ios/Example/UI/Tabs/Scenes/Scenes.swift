//
//  Scenes.swift
//  CleevioDemo
//
//  Created by Diego on 25/12/21.
//

import SwiftUI

struct Scene: Section {
    let name = "Scenes"
    let icon = "3.square.fill"
    
    var content: [Content] {
        [
            PasswordValidationSceneContainerView(),
            PullUpSceneContainerView(),
            PinCodeSceneContainerView(),
            PhoneNumberSceneContainerView()
        ]
    }
}
