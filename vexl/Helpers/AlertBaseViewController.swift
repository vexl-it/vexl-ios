//
//  AlertBaseViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 7/04/22.
//

import UIKit
import Cleevio
import SwiftUI
import Combine

class AlertBaseViewController<T: View>: BaseViewController<T> {

    @Published var error: Error?

    var tempCancelBag: CancelBag = .init()

    override init(rootView: T) {
        super.init(rootView: rootView)
        $error
            .filter { $0 != nil }
            .withUnretained(self)
            .sink { owner, error in
                owner.presentError(title: error?.getMessage()) {
                    owner.error = nil
                }
            }
            .store(in: self.tempCancelBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
