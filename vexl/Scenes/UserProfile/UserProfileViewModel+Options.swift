//
//  UserProfileOptions.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import UIKit

extension UserProfileViewModel {

    struct OptionGroup: Identifiable {
        let id: Int
        let options: [Option]
    }

    enum Option: Int, Identifiable {

        case profilePicture = 0
        case editName

        case contacts
        case facebook

        case pinFaceId
        case currency

        case requestData
        case logout

        var id: Int {
            self.rawValue
        }

        var title: String {
            switch self {
            case .profilePicture:
                return L.userProfileChangePicture()
            case .editName:
                return L.userProfileEditName()
            case .pinFaceId:
                return L.userProfilePinFaceId()
            case .contacts:
                return L.userProfileImportedContacts()
            case .facebook:
                return L.userProfileImportFacebook()
            case .requestData:
                return L.userProfileRequestData()
            case .logout:
                return L.userProfileLogout()
            case .currency:
                return L.userProfileCurrencyTitle()
            }
        }

        func subtitle(withParam param: String = "") -> String? {
            switch self {
            case .contacts:
                return L.userProfileImportedContactsSubtitle(param)
            default:
                return nil
            }
        }

        var iconName: String {
            switch self {
            case .profilePicture:
                return R.image.profile.profilePicture.name
            case .editName:
                return R.image.profile.editName.name
            case .pinFaceId:
                return R.image.profile.pinFaceId.name
            case .contacts:
                return R.image.profile.contactsImported.name
            case .facebook:
                return R.image.profile.importFacebook.name
            case .requestData:
                return R.image.profile.requestData.name
            case .logout:
                return R.image.profile.trash.name
            case .currency:
                return R.image.profile.coins.name
            }
        }

        static var groupedOptions: [OptionGroup] {
            [
                OptionGroup(id: 1, options: [.profilePicture, .editName]),
                OptionGroup(id: 2, options: [.contacts, .facebook]),
                OptionGroup(id: 3, options: [.pinFaceId, .currency]),
                OptionGroup(id: 5, options: [.requestData]),
                OptionGroup(id: 6, options: [.logout])
            ]
        }
    }
}
