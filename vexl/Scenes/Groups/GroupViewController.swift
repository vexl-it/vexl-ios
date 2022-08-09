//
//  GroupViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import SwiftUI
import UIKit
import Cleevio

final class GroupViewController<T: View>: BaseViewController<T> {

    private lazy var backButton: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                   style: .done,
                                   target: self,
                                   action: #selector(onBackAction))
        item.tintColor = .white
        return item
    }()

    @Published var showBackButton: Bool
    var onBack: ActionSubject<Void> = .init()

    init(rootView: T, showBackButton: Bool = true) {
        self.showBackButton = showBackButton
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.setLeftBarButton(backButton, animated: true)
    }

    @objc
    private func onBackAction() {
        onBack.send(())
    }
}
