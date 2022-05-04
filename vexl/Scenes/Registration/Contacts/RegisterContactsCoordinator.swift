//
//  RegisterPhoneContactsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio

final class RegisterContactsCoordinator: BaseCoordinator<RouterResult<Void>> {

    @Inject var authenticationManager: AuthenticationManagerType

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RegisterContactsViewModel(username: authenticationManager.currentUser?.username ?? "",
                                                  avatar: authenticationManager.currentUser?.avatarImage)
        let viewController = RegisterViewController(currentPage: 2,
                                                    numberOfPages: 3,
                                                    rootView: RegisterContactsView(viewModel: viewModel),
                                                    showBackButton: false)

        router.present(viewController, animated: animated)

        viewController
            .onBack
            .sink { _ in
                viewModel.updateToPreviousState()
            }
            .store(in: cancelBag)

        // MARK: - ViewModel Bindings

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$loading
            .assign(to: &viewController.$isLoading)

        let skipTap = viewModel
            .route
            .filter { $0 == .skipTapped }
            .map { _ in RouterResult<Void>.finished(()) }

        let continueTap = viewModel
            .route
            .filter { $0 == .continueTapped }
            .map { _ in RouterResult<Void>.finished(()) }

        return Publishers.Merge(skipTap, continueTap)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
