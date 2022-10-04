//
//  ManagedProfile+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import UIKit
import Combine

extension ManagedProfile {

    private static let avatarQueue = DispatchQueue(label: "Avatar Image Download", qos: .userInitiated)

    var avatar: Data? {
        get { avatarData ?? UIImage(named: R.image.profile.avatar.name)?.pngData() }// TODO: generate random avatar
        set { avatarData = newValue }
    }

    func setAvatar(withURL url: String?) {
        avatarURL = url
        guard let url = url, let dataURL = URL(string: url), let data = try? Data(contentsOf: dataURL) else { return }
        avatar = data
    }

    func generateRandomName() {
        self.name = Self.generateRandomName()
    }

    static func generateRandomName() -> String {
        (0..<Constants.numberOfSyllablesForName)
            .map { _ in Int.random(in: 0..<Constants.randomNameSyllables.count) }
            .map { Constants.randomNameSyllables[$0] }
            .joined()
            .capitalizeFirstLetter
    }
}
