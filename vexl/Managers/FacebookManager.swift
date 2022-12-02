//
//  FacebookManager.swift
//  vexl
//
//  Created by Adam Salih on 06.07.2022.
//

import Foundation
import Combine
import KeychainAccess

enum FacebookError: Error {
    case notImplemented
}

protocol FacebookManagerType {
    var facebookID: String? { get set }
    var facebookToken: String? { get set }
    var facebookHash: String? { get set }
    var facebookSignature: String? { get set }

    func loginWithFacebook(fromViewController viewController: UIViewController?) -> AnyPublisher<String?, Error>
    func update(hash: String, signature: String)
}

final class FacebookManager: FacebookManagerType {
    @KeychainStore(key: .facebookID)
    var facebookID: String?

    @KeychainStore(key: .facebookToken)
    var facebookToken: String?

    @KeychainStore(key: .facebookHash)
    var facebookHash: String?

    @KeychainStore(key: .facebookSignature)
    var facebookSignature: String?

    func update(hash: String, signature: String) {
        facebookHash = hash
        facebookSignature = signature
    }

    func loginWithFacebook(fromViewController viewController: UIViewController? = nil) -> AnyPublisher<String?, Error> {
        Fail(error: FacebookError.notImplemented)
            .eraseToAnyPublisher()
        // TODO: uncomment this whenever we support FBSDKLoginKit again
//        Future { promise in
//            let loginManager = LoginManager()
//            loginManager.logIn(permissions: [.publicProfile, .userFriends], viewController: nil) { result in
//                switch result {
//                case .cancelled:
//                    promise(.success(nil))
//                case let .failed(error):
//                    promise(.failure(error))
//                case let .success(_, _, token):
//                    promise(.success(token))
//                }
//            }
//            Fail(error: FacebookError.notImplemented).eraseToAnyPublisher()
//        }
//        .receive(on: RunLoop.main)
//        .handleEvents(receiveOutput: { [weak self] (facebook: FBSDKLoginKit.AccessToken?) in
//            guard let facebook = facebook, let owner = self else {
//                return
//            }
//            owner.facebookID = facebook.userID
//            owner.facebookToken = facebook.tokenString
//        })
//        .map(\.?.userID)
//        .eraseToAnyPublisher()
    }
}
