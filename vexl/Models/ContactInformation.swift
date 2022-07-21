//
//  ContactInformation.swift
//  vexl
//
//  Created by Diego Espinoza on 2/04/22.
//

import Foundation

struct ContactInformation: Identifiable {

    enum Source: String {
        case phone
        case facebook
    }

    var id: String
    var name: String
    var phone: String
    var avatar: Data?
    var avatarURL: String?
    var isSelected = false
    var source: Source

    var sourceIdentifier: String {
        switch source {
        case .phone:
            return phone
        case .facebook:
            return id
        }
    }

    #if DEBUG || DEVEL
    static func stub() -> [ContactInformation] {
        [
            ContactInformation(id: "1", name: "Diego Espinoza 1", phone: "999 944 222", avatar: nil, source: .phone),
            ContactInformation(id: "2", name: "Diego Espinoza 2", phone: "929 944 222", avatar: nil, source: .phone),
            ContactInformation(id: "3", name: "Diego Espinoza 3", phone: "969 944 222", avatar: nil, source: .phone),
            ContactInformation(id: "4", name: "Diego Espinoza 4", phone: "969 944 222", avatar: nil, source: .phone),
            ContactInformation(id: "5", name: "Diego Test 4", phone: "969 944 222", avatar: nil, source: .phone)
        ]
    }
    #endif
}
