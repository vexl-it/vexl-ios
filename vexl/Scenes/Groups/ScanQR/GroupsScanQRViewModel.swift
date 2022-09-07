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

enum GroupQRScanError: Error {
    case codeNotFound
}

final class GroupsScanQRViewModel: ViewModelType, ObservableObject {

    @Inject var groupManaged: GroupManagerType

    enum ScannerState {
        case initialized
        case cameraAvailable
        case cameraDenied
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case dismissTap
        case mockCodeTap
        case cameraAccessRequest
        case dismissCamera
        case manualInputTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var scannerState: ScannerState = .initialized
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
    var cameraViewModel = CameraPreviewViewModel()

    // MARK: - Initialization

    init() {
        setupActivityBindings()
        setupActions()
        setupCameraAction()
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
            .filter { $0 == .manualInputTap }
            .map { _ in .manualInputTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissCamera }
            .withUnretained(self)
            .sink { owner, _ in
                owner.cameraViewModel.stopSession()
            }
            .store(in: cancelBag)
    }

    private func setupCameraAction() {
        cameraViewModel
            .onResult
            .compactMap { URL(string: $0) }
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

        $scannerState
            .filter { $0 == .cameraAvailable }
            .withUnretained(self)
            .sink { owner, _ in
                owner.cameraViewModel.createSession()
                owner.cameraViewModel.startSession()
            }
            .store(in: cancelBag)

        cameraViewModel
            .onError
            .trackError(primaryActivity.error)
            .sink()
            .store(in: cancelBag)
    }

    private func requestCameraAccess() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .authorized {
            scannerState = .cameraAvailable
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.scannerState = granted ? .cameraAvailable : .cameraDenied
                }
            }
        }
    }

    private func handleUniversalLink(url: URL) -> AnyPublisher<Int, Error> {
        guard let codeStr = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value,
              let code = Int(codeStr) else {
            return Fail(error: GroupQRScanError.codeNotFound)
                .eraseToAnyPublisher()
        }
        return Just(code)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
