//
//  TestViewController.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import RxSwift
import RxCocoa
import SwiftUI

final class TestViewController: UIHostingController<TestView>, ViewModelAttaching {
    var viewModel: TestViewModel!
    var bindings: TestViewModel.Bindings {
        TestViewModel.Bindings(
        )
    }

    // MARK: - UI

    // MARK: - Properties

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Styles

extension TestViewController {
    struct Styles {
    }
}

// MARK: - Create

extension TestViewController {
    static func create() -> TestViewController {
        TestViewController(
            rootView: TestView(viewModel: .init())
        )
    }
}
