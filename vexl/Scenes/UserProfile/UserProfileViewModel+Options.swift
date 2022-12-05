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

        case editAvatar = 0
        case editName

        case contacts
        case facebook

        case pinFaceId
        case currency
        case allowScreenshots

        case groups

        case termsAndPrivacy
        case faq
        case reportIssue
        case logs

        case requestData

        case socialTwitter
        case socialMedium
        case socialVexl

        case logout

        var id: Int {
            self.rawValue
        }

        var title: String? {
            switch self {
            case .editAvatar:
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
                return L.userProfileCurrency()
            case .allowScreenshots:
                return L.userProfileAllowScreenshots()
            case .groups:
                return L.groupsTitle()
            case .termsAndPrivacy:
                return L.userProfileTermsAndPrivacy()
            case .faq:
                return L.userProfileFaq()
            case .reportIssue:
                return L.userProfileReportIssue()
            case .logs:
                return L.userProfileLogs()
            case .socialTwitter:
                return nil
            case .socialMedium:
                return nil
            case .socialVexl:
                return nil
            }
        }

        var attributedTitle: NSMutableAttributedString? {
            switch self {
            case .socialTwitter:
                return setupAttributedTitle(text: L.profileTwitter(), boldText: L.twitter())
            case .socialMedium:
                return setupAttributedTitle(text: L.profileMedium(), boldText: L.medium())
            case .socialVexl:
                return setupAttributedTitle(text: L.profileVexlIt(), boldText: L.vexlIt())
            default:
                return nil
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
            case .editAvatar:
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
            case .allowScreenshots:
                return R.image.profile.allowScreenshot.name
            case .groups:
                return R.image.profile.groups.name
            case .termsAndPrivacy:
                return R.image.profile.termsAndPrivacy.name
            case .faq:
                return R.image.profile.faQ.name
            case .reportIssue:
                return R.image.profile.reportIssue.name
            case .logs:
                return R.image.profile.cpu.name
            case .socialTwitter:
                return R.image.profile.socialTwitter.name
            case .socialMedium:
                return R.image.profile.socialMedium.name
            case .socialVexl:
                return R.image.profile.socialVexl.name
            }
        }

        var url: String? {
            switch self {
            case .socialTwitter:
                return "https://twitter.com/vexl"
            case .socialMedium:
                return "https://blog.vexl.it/"
            case .socialVexl:
                return "https://vexl.it/"
            default:
                return nil
            }
        }

        private func setupAttributedTitle(text: String, boldText: String) -> NSMutableAttributedString {
            let normal = NSMutableAttributedString(string: text)
            normal.bold(text: boldText, font: Appearance.TextStyle.paragraphBold.font)
            return normal
        }

        static var groupedOptions: [OptionGroup] {
            [
                OptionGroup(id: 1, options: [.editAvatar, .editName]),
                // TODO: add facebook back to user profile when facebook works again
                OptionGroup(id: 2, options: [.contacts]), // , .facebook]),
                // TODO: add group back to user profile
                // OptionGroup(id: 3, options: [.groups]),
                OptionGroup(id: 4, options: [.currency]),
                OptionGroup(id: 5, options: [.termsAndPrivacy, .faq, .reportIssue, .logs]),
                OptionGroup(id: 6, options: [.socialTwitter, .socialMedium, .socialVexl]),
                OptionGroup(id: 7, options: [.logout])
            ]
        }

        static var lockedMarketplaceGroupedOptions: [OptionGroup] {
            [
                OptionGroup(id: 1, options: [.editAvatar, .editName]),
                OptionGroup(id: 2, options: [.contacts, .facebook]),
                OptionGroup(id: 3, options: [.currency]),
                OptionGroup(id: 4, options: [.termsAndPrivacy, .faq, .reportIssue]),
                OptionGroup(id: 5, options: [.logout])
            ]
        }
    }

    enum OptionError: Error, LocalizedError {
        case invalidUrl

        var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return L.errorInvalidUrl()
            }
        }
    }
}
