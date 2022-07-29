//
//  ManagedProfile+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import UIKit

extension ManagedProfile {

    var avatar: Data? {
        get { avatarData ?? UIImage(named: R.image.profile.avatar.name)?.pngData() }// TODO: generate random avatar
        set { avatarData = newValue }
    }

    func generateRandomName() {
        self.name = (0..<3)
            .map { _ in Int.random(in: 0..<Constants.randomNameSyllables.count) }
            .map { Constants.randomNameSyllables[$0] }
            .joined()
    }
}
