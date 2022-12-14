//
//  ChatRouter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Alamofire

// swiftlint: disable enum_case_associated_values_count
enum ChatRouter: ApiRouter {
    case createInbox(publicKey: String, pushToken: String?, signedChallenge: SignedChallenge)
    case updateInbox(publicKey: String, pushToken: String, signedChallenge: SignedChallenge)
    case request(inboxPublicKey: String, message: String)
    case requestConfirmation(confirmed: Bool, message: String, inboxPublicKey: String,
                             requesterPublicKey: String, signedChallenge: SignedChallenge)
    case requestChallenge(publicKey: String)
    case pullChat(publicKey: String, signedChallenge: SignedChallenge)
    case deleteChat(publicKey: String, signedChallenge: SignedChallenge)
    case blockInbox(publicKey: String, publicKeyToBlock: String, signedChallenge: SignedChallenge, isBlocked: Bool)
    case sendMessage(senderPublicKey: String, receiverPublicKey: String,
                     message: String, messageType: MessageType, signedChallenge: SignedChallenge)
    case deleteChatMessages(publicKey: String, signedChallenge: SignedChallenge)
    
    var method: HTTPMethod {
        switch self {
        case .createInbox, .request, .requestChallenge, .requestConfirmation, .sendMessage:
            return .post
        case .pullChat, .blockInbox, .updateInbox:
            return .put
        case .deleteChat, .deleteChatMessages:
            return .delete
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .createInbox, .updateInbox:
            return "inboxes"
        case .request:
            return "inboxes/approval/request"
        case .requestChallenge:
            return "challenges"
        case .pullChat:
            return "inboxes/messages"
        case .deleteChat:
            return "inboxes"
        case .deleteChatMessages:
            return "inboxes/messages"
        case .requestConfirmation:
            return "inboxes/approval/confirm"
        case .blockInbox:
            return "inboxes/block"
        case .sendMessage:
            return "inboxes/messages"
        }
    }

    var version: Constants.API.Version? { .v1 }

    var parameters: Parameters {
        switch self {
        case let .createInbox(publicKey, pushToken, signedChallenge):
            guard let pushToken = pushToken else {
                return ["publicKey": publicKey].addSignedChallenge(signedChallenge: signedChallenge)
            }
            return [
                "publicKey": publicKey,
                "token": pushToken
            ].addSignedChallenge(signedChallenge: signedChallenge)
        case let .updateInbox(publicKey, pushToken, signedChallenge):
            return [
                "publicKey": publicKey,
                "token": pushToken
            ].addSignedChallenge(signedChallenge: signedChallenge)
        case let .request(inboxPublicKey, message):
            return [
                "publicKey": inboxPublicKey,
                "message": message
            ]
        case let .requestChallenge(publicKey):
            return [
                "publicKey": publicKey
            ]
        case let .pullChat(publicKey, signedChallenged):
            return [
                "publicKey": publicKey
            ].addSignedChallenge(signedChallenge: signedChallenged)
        case let .requestConfirmation(confirmed, message, inboxPublicKey, requesterPublicKey, signedChallenge):
            return [
                "publicKey": inboxPublicKey,
                "publicKeyToConfirm": requesterPublicKey,
                "message": message,
                "approve": confirmed
            ].addSignedChallenge(signedChallenge: signedChallenge)
        case let .deleteChat(publicKey, signedChallenge):
            return ["publicKey": publicKey].addSignedChallenge(signedChallenge: signedChallenge)
        case let .deleteChatMessages(publicKey, signedChallenge):
            return ["publicKey": publicKey].addSignedChallenge(signedChallenge: signedChallenge)
        case let .blockInbox(publicKey, publicKeyToBlock, signedChallenge, isBlocked):
            return [
                "publicKey": publicKey,
                "publicKeyToBlock": publicKeyToBlock,
                "block": isBlocked
            ].addSignedChallenge(signedChallenge: signedChallenge)
        case let .sendMessage(senderPublicKey, receiverPublicKey, message, messageType, signedChallenge):
            return [
                "senderPublicKey": senderPublicKey,
                "receiverPublicKey": receiverPublicKey,
                "messageType": messageType.rawValue,
                "message": message
            ]
            .addSignedChallenge(signedChallenge: signedChallenge)
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.chatBaseURLString
    }
}

fileprivate extension Parameters {
    func addSignedChallenge(signedChallenge: SignedChallenge) -> Parameters {
        var updatedParams = self
        updatedParams["signedChallenge"] = [
            "challenge": signedChallenge.challenge,
            "signature": signedChallenge.signature
        ]
        return updatedParams
    }
}
