//
//  GroupScanQRViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio
import AVFoundation

final class GroupsScanQRViewModel: ViewModelType, ObservableObject {

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

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case codeScanned(code: String)
        case manualInputTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
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
            .compactMap { action -> String? in
                if case let .codeScan(code) = action { return code }
                return nil
            }
            .map { code -> Route in .codeScanned(code: code) }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .manualInputTap }
            .map { _ -> Route in .manualInputTapped }
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
}
