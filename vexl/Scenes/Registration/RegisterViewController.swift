//
//  RegisterViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import UIKit
import SwiftUI
import Cleevio

final class RegisterViewController<T: View>: BaseViewController<T> {

    private let currentPage: Int
    private let numberOfPages: Int

    private lazy var pageView: RegistrationCounterView = {
        RegistrationCounterView(numberOfItems: self.numberOfPages,
                                currentIndex: self.currentPage)
    }()

    private lazy var backButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                        style: .done,
                        target: self,
                        action: #selector(onBackAction))
    }()

    var onBack: ActionSubject<Void> = .init()

    init(currentPage: Int, numberOfPages: Int, rootView: T) {
        self.currentPage = currentPage
        self.numberOfPages = numberOfPages
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
        navigationItem.leftBarButtonItem = backButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
        navigationItem.leftBarButtonItem = backButton
    }

    @objc
    private func onBackAction() {
        onBack.send(())
    }
}
