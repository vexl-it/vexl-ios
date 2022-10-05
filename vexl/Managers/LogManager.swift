//
//  LogManager.swift
//  vexl
//
//  Created by Adam Salih on 05.10.2022.
//

import Foundation
import Alamofire

protocol LogManagerType {

}

final class LogManager: LogManagerType {
    private(set) var logs: [String] = []
    private let queue: DispatchQueue = DispatchQueue(label: "Log queue")

    init() {
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

    @objc private func requestDidStart(notification: Notification) {
        queue.async {
            guard let dataRequest = notification.request as? DataRequest,
                let task = dataRequest.task,
                let request = task.originalRequest,
                let httpMethod = request.httpMethod,
                let requestURL = request.url
                else {
                    return
            }

            print("\(httpMethod) '\(requestURL.absoluteString)':")

        }
    }

    @objc private func requestDidFinish(notification: Notification) {
        queue.async {
            guard let dataRequest = notification.request as? DataRequest,
                let task = dataRequest.task,
                let metrics = dataRequest.metrics,
                let request = task.originalRequest,
                let httpMethod = request.httpMethod,
                let requestURL = request.url
                else {
                    return
            }

            let elapsedTime = metrics.taskInterval.duration

            if let error = task.error {
                print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                print(error)
            } else {
                guard let response = task.response as? HTTPURLResponse else {
                    return
                }

                print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")

                let headers = response.allHeaderFields
                print("Headers: [")
                for (key, value) in headers {
                    print("  \(key): \(value)")
                }
                print("]")

                guard let data = dataRequest.data else {
                    return
                }

                print("Body:")

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    }
                } catch {
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        print(string)
                    }
                }
            }
        }

    }
}
