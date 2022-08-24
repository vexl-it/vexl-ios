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
    var logoUrl: String?
    var logoData: Data?
    var logoExtension: String?
    var createdAt: Int?
    var expirationAt: Int
    var closureAt: Int
    var code: Int?
    var memberCount: Int?

    var asJson: [String: Any] {
        var json: [String: Any] = [
            "name": name,
            "expirationAt": expirationAt,
            "closureAt": closureAt
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
        self.logoExtension = logoData == nil ? nil : "jpg"
        self.expirationAt = Int(expiration.timeIntervalSince1970)
        self.closureAt = Int(closureAt.timeIntervalSince1970)
    }

    init?(group: ManagedGroup) {
        guard let name = group.name, let expirationDate = group.expiration, let closureAt = group.closureAt else {
            return nil
        }
        self.name = name
        self.closureAt = Int(closureAt.timeIntervalSince1970)
        expirationAt = Int(expirationDate.timeIntervalSince1970)
        uuid = group.uuid
        logoUrl = group.logoURL?.absoluteString
        logoData = group.logo
        if let createdAt = group.createdAt?.timeIntervalSince1970 {
            self.createdAt = Int(createdAt)
        }
        code = Int(group.code)
        memberCount = group.members?.count ?? 0
    }

    @discardableResult
    func decode(context: NSManagedObjectContext, userRepository: UserRepositoryType, into group: ManagedGroup) -> ManagedGroup? {
        guard let uuid = uuid,
              let logoUrl = logoUrl,
              let createdAt = createdAt,
              let code = code else {
            return nil
        }
        group.uuid = uuid
        group.name = name
        group.createdAt = Date(timeIntervalSince1970: TimeInterval(createdAt))
        group.expiration = Date(timeIntervalSince1970: TimeInterval(expirationAt))
        group.closureAt = Date(timeIntervalSince1970: TimeInterval(closureAt))
        group.code = Int64(code)
        group.hexColor = "#530B6E"
        if let url = URL(string: logoUrl) {
            group.logoURL = url
            // TODO: load logo from url
//            group.logo = try? Data(contentsOf: url)
            group.logo = R.image.chainCamp()?.pngData()
        }
        return group
    }
}
