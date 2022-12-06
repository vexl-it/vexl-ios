//
//  ManagedProfile+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import UIKit
import SwiftUI

extension ManagedProfile {

    var avatar: Data? {
        get { avatarData ?? Self.generateRandomAvatar() }
        set { avatarData = newValue }
    }

    func generateRandomName() {
        self.name = Self.generateRandomName()
    }

    func generateRandomAvatar() {
        self.avatar = Self.generateRandomAvatar()
    }

    static func generateRandomName() -> String {
        (0..<Constants.numberOfSyllablesForName)
            .map { _ in Int.random(in: 0..<Constants.randomNameSyllables.count) }
            .map { Constants.randomNameSyllables[$0] }
            .joined()
            .capitalizeFirstLetter
    }

    static func getRandomAvatarName() -> String {
        Constants.anonymousAvatarNames[Int.random(in: 0..<Constants.anonymousAvatarNames.count)]
    }

    static func generateRandomAvatar() -> UIImage? {
        UIImage(named: getRandomAvatarName())
    }

    static func generateRandomAvatar() -> Data? {
        UIImage(named: getRandomAvatarName())?
            .jpegData(compressionQuality: Constants.imageCompressionQuality)
    }

    static func generateRandomAvatar() -> Image {
        Image(getRandomAvatarName())
    }
}
