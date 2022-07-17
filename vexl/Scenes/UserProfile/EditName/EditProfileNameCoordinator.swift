//
//  EditProfileNameCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/07/22.
//

import Foundation
import Cleevio
import Combine

final class EditProfileNameCoordiantor: BaseCoordinator<RouterResult<Void>> {

    let animated: Bool
    let router: Router

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let viewModel = EditProfileNameViewModel()
        let viewController = BaseViewController(rootView: EditProfileNameView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
