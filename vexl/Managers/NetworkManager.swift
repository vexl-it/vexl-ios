//
//  NetworkManager.swift
//  vexl
//
//  Created by Adam Salih on 10.07.2022.
//

import Foundation
import Network
import Combine

protocol NetworkManagerType {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

final class NetworkManager: NetworkManagerType {
    private let interfaceMonitor: NWPathMonitor

    private let threadQueue = DispatchQueue(label: "interfaceMonitorQueue")
    private var cancellables: Set<AnyCancellable> = Set()

    private(set) var running = false

    @Published var isConnected: Bool = true

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $isConnected.removeDuplicates().eraseToAnyPublisher()
    }

    init() {
        interfaceMonitor = .init()
        interfaceMonitor.pathUpdateHandler = { [weak self] path in
            self?.handler(path: path)
        }
        start()
    }

    func start() {
        guard !running else { return }
        running = true
        interfaceMonitor.start(queue: threadQueue)
    }

    private func handler(path: NWPath) {
        isConnected = path.status == .satisfied
    }
}
