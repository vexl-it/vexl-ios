//
//  GroupPayload.swift
//  vexl
//
//  Created by Adam Salih on 06.08.2022.
//

import UIKit
import CoreData

struct GroupEnvelope: Codable {
    let groupResponse: [GroupPayload]
}

struct GroupPayload: Codable {
    var uuid: String?
    var name: String
    var logoUrl: URL?
    var logoData: Data?
    var logoExtension: String?
    var createdAt: Int?
    var expiration: Int
    var closure: Int
    var code: Int?
    var memberCount: Int?

    var asJson: [String: Any] {
        var json: [String: Any] = [
            "name": name,
            "expiration": expiration,
            "closureAt": closure
        ]
        if let logoData = logoData, let logoExtension = logoExtension {
            json["logo"] = [
                "data": logoData.base64EncodedString(),
                "extension": logoExtension
            ]
        }
        return json
    }

    init(name: String, logo: UIImage, expiration: Date, closureAt: Date) {
        self.name = name
        self.logoData = logo.jpegData(compressionQuality: 1)
        self.logoExtension = logoData.flatMap { _ in "jpg" }
        self.expiration = Int(expiration.timeIntervalSince1970)
        self.closure = Int(closureAt.timeIntervalSince1970)
    }

    init?(group: ManagedGroup) {
        guard let name = group.name, let expirationDate = group.expiration, let closureAt = group.closureAt else {
            return nil
        }
        self.name = name
        self.closure = Int(closureAt.timeIntervalSince1970)
        expiration = Int(expirationDate.timeIntervalSince1970)
        uuid = group.uuid
        logoUrl = group.logoURL
        logoData = group.logo
        if let createdAt = group.createdAt?.timeIntervalSince1970 {
            self.createdAt = Int(createdAt)
        }
        code = Int(group.code)
        memberCount = group.members?.count ?? 0
    }

    func decode(context: NSManagedObjectContext, userRepository: UserRepositoryType, into group: ManagedGroup) -> ManagedGroup? {
        guard let uuid = uuid,
              let logoUrl = logoUrl,
              let createdAt = createdAt,
              let code = code else {
            return nil
        }
        group.uuid = uuid
        group.name = name
        group.logoURL = logoUrl
        group.logo = try? Data(contentsOf: logoUrl)
        group.createdAt = Date(timeIntervalSince1970: TimeInterval(createdAt))
        group.expiration = Date(timeIntervalSince1970: TimeInterval(expiration))
        group.closureAt = Date(timeIntervalSince1970: TimeInterval(closure))
        group.code = Int64(code)
        return group
    }
}
