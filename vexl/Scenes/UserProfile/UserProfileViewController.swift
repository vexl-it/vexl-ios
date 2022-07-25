//
//  UserProfileViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 24/07/22.
//

import Cleevio
import UIKit
import MessageUI
import SwiftUI

final class UserProfileViewController<T: View>: BaseViewController<T>, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    func presentEmailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }

        let emailComposerViewController = makeBugReportMailComposeController()
        present(emailComposerViewController, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }

    private func makeBugReportMailComposeController() -> UIViewController {
        let controller = MFMailComposeViewController()
        controller.delegate = self
        controller.mailComposeDelegate = self
        controller.setToRecipients([Constants.supportEmail])

        let appVersion = "\(UIDevice.appVersion)-\(UIDevice.buildNumber)"
        let deviceModelName = UIDevice.current.name
        let deviceSystemVersion = UIDevice.current.systemVersion
        controller.setMessageBody(
            """
            \(L.userProfileReportErrorEmailbody())
            \(appVersion) - \(deviceModelName) - \(deviceSystemVersion)
            """,
            isHTML: false
        )

        return controller
    }
}
