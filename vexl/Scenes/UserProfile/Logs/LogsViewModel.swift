//
//  LogsViewModel.swift
//  vexl
//
//  Created by Adam Salih on 06.10.2022.
//

import SwiftUI
import Cleevio
import Combine

final class LogsViewModel: ViewModelType, ObservableObject {

    @Inject var logManager: LogManagerType

    enum UserAction: Equatable {
        case copyTap
        case dismissTap
        case toggleLogsTap(enable: Bool)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var logs: [Log] = []
    @Published var lastLog: Log = Log(message: "No logs")
    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var isCollectingEnabled: Bool = true
    @Published var error: Error?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    private let cancelBag: CancelBag = .init()

    init() {
        setupActivityBindings()
        setupActionBindings()
    }

    private func setupActivityBindings() {
        isCollectingEnabled = logManager.collectLogs

        logManager
            .logPublisher
            .withUnretained(self)
            .sink { owner, logs in
                owner.logs = logs

                if let lastLog = logs.last {
                    withAnimation {
                        owner.lastLog = lastLog
                    }
                }
            }
            .store(in: cancelBag)

        $logs
            .eraseToAnyPublisher()
            .compactMap(\.last)
            .assign(to: &$lastLog)

        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupActionBindings() {
        let action = action.share()

        action
            .filter { $0 == .copyTap }
            .withUnretained(self)
            .sink { owner, _ in
                UIPasteboard.general.string = owner.logs
                    .map { "[\($0.formattedDate)]: \($0.message)" }
                    .joined(separator: "\n\n")
            }
            .store(in: cancelBag)

        $isCollectingEnabled
            .withUnretained(self)
            .sink { owner, enable in
                owner.logManager.collectLogs(enable: enable)
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap }
            .asVoid()
            .map { () -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
