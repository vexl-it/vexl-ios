//
//  RxViewController.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import RxSwift
import RxCocoa

class RxViewController: UIViewController {

    let disposeBag = DisposeBag()
    private(set) var visibleDisposeBag: DisposeBag!

    override func viewWillAppear(_ animated: Bool) {
        visibleDisposeBag = DisposeBag()
        setupVisibleBindings(for: visibleDisposeBag!)

        super.viewWillAppear(animated)

        setupNavigationBar()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        visibleDisposeBag = nil
    }

    func setupVisibleBindings(for visibleDisposeBag: DisposeBag) { }

    func setupNavigationBar() {}
}
