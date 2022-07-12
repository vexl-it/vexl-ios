//
//  EncryptionService.swift
//  vexl
//
//  Created by Adam Salih on 19.04.2022.
//

import Combine

protocol CryptoServiceType {
    func hashSHA(data: String) -> Future<String, Error>

    func hashHMAC(password: String, message: String) -> Future<String, Error>
    func verifyHMAC(password: String, message: String, digest: String) -> Future<Bool, Never>

    func signECDSA(keys: ECCKeys, message: String) -> Future<String, Error>
    func verifyECDSA(publicKey: String, message: String, signature: String) -> Future<Bool, Never>

    func encryptECIES(publicKey: String, secret: String) -> Future<String, Error>
    func decryptECIES(keys: ECCKeys, cipher: String) -> Future<String, Error>

    func encryptAES(password: String, secret: String) -> Future<String, Error>
    func decryptAES(password: String, cipher: String) -> Future<String, Error>
}

class CryptoService: CryptoServiceType {
    func hashSHA(data: String) -> Future<String, Error> {
        Future { promise in
            do {
                let digest = try SHA.hash(data: data)
                promise(.success(digest))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func hashHMAC(password: String, message: String) -> Future<String, Error> {
        Future { promise in
            do {
                let digest = try HMAC.hash(password: password, message: message)
                promise(.success(digest))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func verifyHMAC(password: String, message: String, digest: String) -> Future<Bool, Never> {
        Future { promise in
            let isVerified = HMAC.verify(password: password, message: message, digest: digest)
            promise(.success(isVerified))
        }
    }

    func signECDSA(keys: ECCKeys, message: String) -> Future<String, Error> {
        Future { promise in
            do {
                let signature = try ECC.sign(keys: keys, message: message)
                promise(.success(signature))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func verifyECDSA(publicKey: String, message: String, signature: String) -> Future<Bool, Never> {
        Future { promise in
            let isVerified = ECC.verify(publicKey: publicKey, message: message, signature: signature)
            promise(.success(isVerified))
        }
    }

    func encryptECIES(publicKey: String, secret: String) -> Future<String, Error> {
        Future { promise in
            do {
                let secret = try ECC.encrypt(publicKey: publicKey, secret: secret)
                promise(.success(secret))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func decryptECIES(keys: ECCKeys, cipher: String) -> Future<String, Error> {
        Future { promise in
            do {
                let secret = try ECC.decrypt(keys: keys, cipher: cipher)
                promise(.success(secret))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func encryptAES(password: String, secret: String) -> Future<String, Error> {
        Future { promise in
            do {
                let secret = try AES.encrypt(password: password, secret: secret)
                promise(.success(secret))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func decryptAES(password: String, cipher: String) -> Future<String, Error> {
        Future { promise in
            do {
                let secret = try AES.decrypt(password: password, cipher: cipher)
                promise(.success(secret))
            } catch {
                promise(.failure(error))
            }
        }
    }
}
