//
//  LogManager.swift
//  vexl
//
//  Created by Adam Salih on 05.10.2022.
//

import Foundation
import Alamofire
import Combine
import Cleevio

protocol LogManagerType {
    var logPublisher: AnyPublisher<[Log], Never> { get }
    var collectLogs: Bool { get }

    func collectLogs(enable: Bool)
    func log(notification: NotificationType)
    func log(message: String)
}

struct Log: Identifiable, Equatable {
    let id: UUID = .init()
    var date: Date = Date()
    var message: String

    var formattedDate: String {
        Formatters.logFormatter.string(from: date)
    }
}

final class LogManager: LogManagerType {
    var logPublisher: AnyPublisher<[Log], Never> {
        $logs
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    @UserDefault(.inappLoggingEnabled, defaultValue: true) private(set) var collectLogs: Bool
    @Published private var logs: [Log] = []

    private let operationQueue = OperationQueue()
    private let cancelBag: CancelBag = .init()

    init() {
        operationQueue.maxConcurrentOperationCount = 1

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(
            self,
            selector: #selector(requestDidStart(notification:)),
            name: Request.didResumeNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(requestDidFinish(notification:)),
            name: Request.didFinishNotification,
            object: nil
        )
    }

    func collectLogs(enable: Bool) {
        collectLogs = enable
    }

    func log(message: String) {
        guard collectLogs else {
            return
        }
        if logs.count > Constants.maxLogLimit {
            logs.removeFirst()
        }
        logs.append(Log(message: message))
    }

    func log(notification: NotificationType) {
        operationQueue.addOperation { [weak self] in
            var message = "Notification received\n"
            message += "type: \(notification.rawValue)"
            self?.log(message: message)
        }
    }

    @objc
    private func requestDidStart(notification: Notification) {
        operationQueue.addOperation { [weak self] in
            guard let dataRequest = notification.request as? DataRequest,
                let task = dataRequest.task,
                let request = task.originalRequest,
                let httpMethod = request.httpMethod,
                let requestURL = request.url
                else {
                return
            }

            var message = "Server request\n"
            message += "url: \(requestURL.absoluteString)\n"
            message += "method: \(httpMethod)"

            self?.log(message: message)
        }
    }

    @objc
    private func requestDidFinish(notification: Notification) {
        operationQueue.addOperation { [weak self] in
            guard let dataRequest = notification.request as? DataRequest,
                let task = dataRequest.task,
                let metrics = dataRequest.metrics,
                let request = task.originalRequest,
                let requestURL = request.url,
                let response = task.response as? HTTPURLResponse
                else {
                return
            }

            let elapsedTime = metrics.taskInterval.duration

            var message = "Server response\n"
            message += "url: \(requestURL.absoluteString)\n"
            message += "response: \(String(response.statusCode))\n"
            message += "elapsed time: \(String(format: "%.04f", elapsedTime))s"

            self?.log(message: message)
        }
    }
}
