//
//  UIDevice+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import UIKit

extension UIDevice {

    static var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }

        return "undefined"
    }

    static var buildNumber: String {
        if let number = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return number
        }

        return "undefined"
    }

    static var bundleIdentifier: String {
        if let identifier = Bundle.main.bundleIdentifier {
            return identifier
        }

        return "undefined"
    }

    static var targetName: String? {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }
}
