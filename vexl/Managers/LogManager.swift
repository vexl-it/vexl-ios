//
//  LogManager.swift
//  vexl
//
//  Created by Adam Salih on 05.10.2022.
//

import Foundation
import Alamofire
import Combine

protocol LogManagerType {
    var logPublisher: AnyPublisher<[Log], Never> { get }

    func log(notification: NotificationType)
    func log(message: String)
}

struct Log {
    var date: Date = Date()
    var message: String
}

final class LogManager: LogManagerType {
    var logPublisher: AnyPublisher<[Log], Never> {
        $logs
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    @Published private var logs: [Log] = []
    private let operationQueue = OperationQueue()

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

    func log(message: String) {
        if logs.count > Constants.maxLogLimit {
            logs.removeFirst()
        }
        logs.append(Log(message: message))
    }

    func log(notification: NotificationType) {
        operationQueue.addOperation { [weak self] in
            self?.log(message: "Notification received: \(notification.rawValue)")
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

            self?.log(message: "\(httpMethod) '\(requestURL.absoluteString)':")
        }
    }

    @objc
    private func requestDidFinish(notification: Notification) {
        operationQueue.addOperation { [weak self] in
            guard let dataRequest = notification.request as? DataRequest,
                let task = dataRequest.task,
                let metrics = dataRequest.metrics,
                let request = task.originalRequest,
                let httpMethod = request.httpMethod,
                let requestURL = request.url
                else {
                return
            }

            var message = ""

            let elapsedTime = metrics.taskInterval.duration

            if let error = task.error {
                message = "[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]"
                message += "\(error)"
            } else {
                guard let response = task.response as? HTTPURLResponse else {
                    return
                }
                message = "\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:"
            }

            self?.log(message: message)
        }
    }
}
