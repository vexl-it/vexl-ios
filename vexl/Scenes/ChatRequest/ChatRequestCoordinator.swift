//
//  ChatRequestCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import Foundation
import Cleevio
import Combine

final class ChatRequestCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    @Inject private var deeplinkManager: DeeplinkManagerType

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let viewModel = ChatRequestViewModel()
        let viewController = BaseViewController(rootView: ChatRequestView(viewModel: viewModel))

        router.present(viewController, animated: true)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let deeplinkDismiss = deeplinkManager.goToInboxTab
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss.merge(with: deeplinkDismiss)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
