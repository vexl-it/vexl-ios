//
//  ViewModelAttaching.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit

protocol ViewModelAttaching: AnyObject {
    associatedtype ViewModel: ViewModelType

    var bindings: ViewModel.Bindings { get }
    var viewModel: ViewModel! { get set }

    static func create() -> Self

    func attach(wrapper: ViewModelWrapper<ViewModel>) -> ViewModel
    func setupUI()
    func arrangeSubviews()
    func layout()
    func setupBindings(viewModel: ViewModel)
}

// swiftlint:disable empty_functions
extension ViewModelAttaching where Self: UIViewController {
    static func create() -> Self { .init() }

    @discardableResult
    func attach(wrapper: ViewModelWrapper<ViewModel>) -> ViewModel {
        viewModel = wrapper.bind(bindings)
        loadViewIfNeeded()
        setupUI()
        arrangeSubviews()
        layout()
        setupBindings(viewModel: viewModel)
        return viewModel
    }

    func setupUI() {}

    func arrangeSubviews() {}

    func layout() {}

    func setupBindings(viewModel: ViewModel) {}
}
