//
//  vexlTests.swift
//  vexlTests
//
//  Created by Adam Salih on 05.02.2022.
//

import XCTest
@testable import vexl

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

    func testSHA() throws {
        let digestSHA = try cryptoService.hashSHA(data: message)
        XCTAssertEqual(digestSHA, "uwtXAF8BAYsZwnjFUnOmARj/3T5XkMzIpIytA5B/pSE=")
    }

    func testHMAC() throws {
        let digest = try cryptoService.hashHMAC(password: password, message: message)
        let verifiedHMAC = cryptoService.verifyHMAC(password: password, message: message, digest: digest)
        XCTAssertTrue(verifiedHMAC)
    }

    func testAES() throws {
        let cipher = try cryptoService.encryptAES(password: password, secret: message)
        let decryptedMessage = try cryptoService.decryptAES(password: password, cipher: cipher)
        XCTAssertEqual(decryptedMessage, message)
    }

    func testECDSA() throws {
        let keys = ECCKeys()
        XCTAssertNotNil(keys.privateKey)
        let signature = try cryptoService.signECDSA(keys: keys, message: message)
        let verifiedECDSA = cryptoService.verifyECDSA(publicKey: keys.publicKey, message: message, signature: signature)
        XCTAssertTrue(verifiedECDSA)
    }

    func testECIES() throws {
        let keys = ECCKeys()
        XCTAssertNotNil(keys.privateKey)
        let cipher = try cryptoService.encryptECIES(publicKey: keys.publicKey, secret: message)
        let decryptedMessage = try cryptoService.decryptECIES(keys: keys, cipher: cipher)
        XCTAssertEqual(decryptedMessage, message)
    }
}
