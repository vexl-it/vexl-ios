//
//  URLRequest+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import UIKit

extension URLRequest {
    mutating func setDefaultHeaders() {
        setValue(ApiInterceptor.xPlatformHeaderValue, forHTTPHeaderField: ApiInterceptor.xPlatformHeaderKey)
        let uuid: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        setValue(uuid, forHTTPHeaderField: ApiInterceptor.xInstallHeaderKey)
    }
}
