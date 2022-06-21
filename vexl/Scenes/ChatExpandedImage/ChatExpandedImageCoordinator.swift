//
//  ChatImagePreviewCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 16/06/22.
//

import Foundation
import Cleevio

final class ChatExpandedImageCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let image: Data
    private let router: Router
    private let animated: Bool

    init(image: Data, router: Router, animated: Bool) {
        self.image = image
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = ChatExpandedImageViewModel(image: image)
        let viewController = BaseViewController(rootView: ChatExpandedImageView(viewModel: viewModel))

        router.present(viewController, animated: true)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
