//
//  PullUpViewPosition.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/15/21.
//

import SwiftUI

public enum PullUpViewPosition: Equatable, CaseIterable {
    case full
    case middle
    case bottom

    var offset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let positionHeight = screenHeight * screenPercentage
        return screenHeight - positionHeight
    }

    var screenPercentage: CGFloat {
        switch self {
        case .full:
            return 0.9
        case .middle:
            return 0.4
        case .bottom:
            return 0.2
        }
    }
}
