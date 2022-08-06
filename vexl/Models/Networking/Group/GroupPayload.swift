//
//  GroupPayload.swift
//  vexl
//
//  Created by Adam Salih on 06.08.2022.
//

import Foundation

struct GroupEnvelope: Codable {
    let groupResponse: [GroupPayload]
}

struct GroupPayload: Codable {
    let uuid: String?
    let name: String
    let logoUrl: URL?
    let logoData: Data?
    let createdAt: Date?
    let expiration: Date
    let closureAt: Date
    let code: Int?
    let memberCount: Int?

    var asJson: [String: Any] {
        var json: [String: Any] = [
            "name": name,
            "expiration": Formatters.dateApiFormatter.string(from: expiration),
            "closureAt": Formatters.dateApiFormatter.string(from: closureAt)
        ]
        if let logoData = logoData {
            json["logo"] = [
                "data": logoData.base64EncodedString(),
                "extension": "png"
            ]
        }
        return json
    }

    init?(group: ManagedGroup) {
        guard let name = group.name, let expirationDate = group.expirationAt, let closureAt = group.closureAt else {
            return nil
        }
        self.name = name
        self.closureAt = closureAt
        expiration = expirationDate
        uuid = group.uuid
        logoUrl = group.logoURL
        logoData = group.logo
        createdAt = group.createdAt
        code = Int(group.code)
        memberCount = group.members?.count ?? 0
    }
}
