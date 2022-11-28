//
//  UIScreen+.swift
//  vexl
//
//  Created by Diego Espinoza on 18/03/22.
//

import UIKit

extension UIScreen {
    var width: CGFloat { self.bounds.width }
    var height: CGFloat { self.bounds.height }
}

/// Using aspect ratio in the device itself to calculate an appropiate height or width
///  that we can use in small devices where the design was made for bigger devices.
extension UIScreen {
    // iPhone 11 Pro reference width and height
    static let referenceWidth: CGFloat = 375
    static let referenceHeigth: CGFloat = 812

    static var ratio: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeigth = UIScreen.main.bounds.height
        let useWidth = (screenWidth / referenceWidth) < (screenHeigth / referenceHeigth)
        return useWidth ? (screenWidth / referenceWidth) : (screenHeigth / referenceHeigth)
    }
    
    static let insets: UIEdgeInsets = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets ?? .zero
    static var isSmallScreen: Bool { Self.main.height < Self.referenceHeigth }
}

extension CGFloat {
    var adjusted: CGFloat { (self * UIScreen.ratio).rounded() }
}

extension Double {
    var adjusted: CGFloat { (self * UIScreen.ratio).rounded() }
}

extension Int {
    var adjusted: CGFloat { (CGFloat(self) * UIScreen.ratio).rounded() }
}
