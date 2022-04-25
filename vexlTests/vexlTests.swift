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
        let digest = try message.sha.hash()
        XCTAssertEqual(digest, "uwtXAF8BAYsZwnjFUnOmARj/3T5XkMzIpIytA5B/pSE=")
    }

    func testHMAC() throws {
        let digest = try message.hmac.hash(password: password)
        let isVerified = digest.hmac.verify(password: password, message: message)
        XCTAssertTrue(isVerified)
    }

    func testAES() throws {
        let cipher = try message.aes.encrypt(password: password)
        let decryptedMessage = try cipher.aes.decrypt(password: password)
        XCTAssertEqual(decryptedMessage, message)
    }

    func testECDSA() throws {
        let keys = ECCKeys()
        XCTAssertNotNil(keys.privateKey)
        let signature = try message.ecc.sign(keys: keys)
        let isVerified = signature.ecc.verify(publicKey: keys.publicKey, message: message)
        XCTAssertTrue(isVerified)
    }

    func testECIES() throws {
        let keys = ECCKeys()
        XCTAssertNotNil(keys.privateKey)
        let cipher = try message.ecc.encrypt(publicKey: keys.publicKey)
        let decryptedMessage = try cipher.ecc.decrypt(keys: keys)
        XCTAssertEqual(decryptedMessage, message)
    }
}
