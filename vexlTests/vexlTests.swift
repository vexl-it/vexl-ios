//
//  vexlTests.swift
//  vexlTests
//
//  Created by Adam Salih on 05.02.2022.
//

import XCTest
@testable import vexl

// swiftlint:disable force_try
class VexlTests: XCTestCase {
    let cryptoService: CryptoServiceType = CryptoService()

    let message: String = "secret message"
    let password: String = "secret123"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSHA() {
        XCTAssertNoThrow(try cryptoService.hashSHA(data: message))
        let digestSHA = try! cryptoService.hashSHA(data: message)
        XCTAssertEqual(digestSHA, "uwtXAF8BAYsZwnjFUnOmARj/3T5XkMzIpIytA5B/pSE=")
    }

    func testHMAC() {
        XCTAssertNoThrow(try cryptoService.hashHMAC(password: password, message: message))
        let digest = try! cryptoService.hashHMAC(password: password, message: message)
        let verifiedHMAC = cryptoService.verifyHMAC(password: password, message: message, digest: digest)
        XCTAssertTrue(verifiedHMAC)
    }

    func testAES() {
        XCTAssertNoThrow(try cryptoService.encryptAES(password: password, secret: message))
        let cipher = try! cryptoService.encryptAES(password: password, secret: message)
        XCTAssertNoThrow(try cryptoService.decryptAES(password: password, cipher: cipher))
        let decryptedMessage = try! cryptoService.decryptAES(password: password, cipher: cipher)
        XCTAssertEqual(decryptedMessage, message)
    }

    func testECDSA() {
        let keys = ECKeys()
        XCTAssertNotNil(keys.privateKey)
        XCTAssertNoThrow(try cryptoService.signECDSA(keys: keys, message: message))
        let signature = try! cryptoService.signECDSA(keys: keys, message: message)
        let verifiedECDSA = cryptoService.verifyECDSA(publicKey: keys.publicKey, message: message, signature: signature)
        XCTAssertTrue(verifiedECDSA)
    }

    func testECIES() {
        let keys = ECKeys()
        XCTAssertNotNil(keys.privateKey)
        XCTAssertNoThrow(try cryptoService.encryptECIES(publicKey: keys.publicKey, secret: message))
        let cipher = try! cryptoService.encryptECIES(publicKey: keys.publicKey, secret: message)
        XCTAssertNoThrow(try cryptoService.decryptECIES(keys: keys, cipher: cipher))
        let decryptedMessage = try! cryptoService.decryptECIES(keys: keys, cipher: cipher)
        XCTAssertEqual(decryptedMessage, message)
    }
}
