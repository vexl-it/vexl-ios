//
//  GroupScanQRViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio
import AVFoundation
import Combine
import FirebaseDynamicLinks

final class GroupsScanQRViewModel: ViewModelType, ObservableObject {

    @Inject var groupManaged: GroupManagerType

    // MARK: - Properties for simulator/mock testing

    var mockCode = "111111"
    var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case dismissTap
        case cameraAccessRequest
        case codeScan(code: String)
        case manualInputTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var showCamera = false
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case codeScanned
        case manualInputTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()
    let scanInterval = 1.0

    // MARK: - Initialization

    init() {
        setupActivityBindings()
        setupActions()
    }

    private func setupActivityBindings() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupActions() {
        action
            .filter { $0 == .cameraAccessRequest }
            .withUnretained(self)
            .sink { owner, _ in
                owner.requestCameraAccess()
            }
            .store(in: cancelBag)

        action
            .compactMap { action -> URL? in
                if case let .codeScan(code) = action { return URL(string: code) }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, url in
                owner.handleUniversalLink(url: url)
                    .materialize()
                    .compactMap(\.value)
            }
            .flatMap { [groupManaged, primaryActivity] code in
                groupManaged
                    .joinGroup(code: code)
                    .track(activity: primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .map { _ in .codeScanned }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .manualInputTap }
            .map { _ in .manualInputTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }

    private func requestCameraAccess() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .authorized {
            showCamera = true
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.sync {
                    self?.showCamera = granted
                }
            }
        }
    }

    private func handleUniversalLink(url: URL) -> AnyPublisher<Int, Error> {
        Future { promise in
            DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamiclink, error in
                guard error == nil else {
                    promise(.failure(GroupError.invalidQRCode))
                    return
                }

                guard let url = dynamiclink?.url,
                      let code = url.valueOf("code"),
                      let intCode = Int(code) else { return }
                promise(.success(intCode))
            }
        }
        .eraseToAnyPublisher()
    }
}
