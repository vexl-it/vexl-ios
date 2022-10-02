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

    func getAvatar() -> AnyPublisher<Data?, Never> {
        let placeholder = UIImage(named: R.image.profile.avatar.name)?.pngData()

        return Future { [weak self] promise in
            guard let owner = self else {
                promise(.success(placeholder))
                return
            }

            if let avatarData = owner.avatarData {
                promise(.success(avatarData))
            } else if let avatarURL = owner.avatarURL, let url = URL(string: avatarURL) {
                Self.avatarQueue.async {
                    let data = try? Data(contentsOf: url)
                    promise(.success(data))
                }
            } else {
                promise(.success(placeholder))
            }
        }
        .eraseToAnyPublisher()
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
