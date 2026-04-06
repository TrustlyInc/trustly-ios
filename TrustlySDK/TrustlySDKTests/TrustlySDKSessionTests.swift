//
//  TrustlySDKSessionTests.swift
//  TrustlySDKTests
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import XCTest
@testable import TrustlySDK

final class TrustlySDKSessionTests: TrustlySDKTestCase {

    func testSessionCidIsValidForFreshSession() {
        let sessionCid = SessionCid(sessionId: "session-id", expirationTime: Date().addingTimeInterval(-300))

        XCTAssertTrue(sessionCid.isValid(expirationTimeLimit: SessionCid.EXPIRATION_TIME_LIMIT))
    }

    func testSessionCidIsInvalidAfterExpirationLimit() {
        let sessionCid = SessionCid(sessionId: "session-id", expirationTime: Date().addingTimeInterval(-7200))

        XCTAssertFalse(sessionCid.isValid(expirationTimeLimit: SessionCid.EXPIRATION_TIME_LIMIT))
    }

    func testGetOrCreateSessionCidReturnsCachedValueWhenStillValid() {
        let cachedSessionCid = SessionCid(sessionId: "cached-session", expirationTime: Date())
        saveData(cachedSessionCid, keyStorage: .session_cid)

        let result = getOrCreateSessionCid("new-session")

        XCTAssertEqual(result, "cached-session")
    }

    func testGetOrCreateSessionCidReplacesExpiredValue() {
        let expiredSessionCid = SessionCid(sessionId: "expired-session", expirationTime: Date().addingTimeInterval(-7200))
        saveData(expiredSessionCid, keyStorage: .session_cid)

        let result = getOrCreateSessionCid("new-session")
        let storedSessionCid: SessionCid? = readDataFrom(keyStorage: .session_cid)

        XCTAssertEqual(result, "new-session")
        XCTAssertEqual(storedSessionCid?.sessionId, "new-session")
    }

    func testCidHelpersExtractExpectedSegments() {
        XCTAssertEqual(getFingerPrint(deviceUUID: "1234-ABCD-5678-FFFF"), "ABCD")
        XCTAssertNil(getFingerPrint(deviceUUID: nil))
        XCTAssertEqual(getRandomKey(randomUUID: "1111-2222-RANDOM-4444"), "RANDOM")
        XCTAssertEqual(getTimestampBase36(timeInMilliseconds: 35), "Z")
    }
}