//
//  SessionManagerTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 06/06/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class SessionManagerTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testGetFingerprintReturnSecondGroupFromUUID() throws {
        
        let fakeDeviceUUID = "b6815296-04b3-11ee-be56-0242ac120002"
        let fingerprint = getFingerPrint(deviceUUID: fakeDeviceUUID)
        
        let expectdFingerPrint = "04b3"
        
        XCTAssertEqual(expectdFingerPrint, fingerprint)

    }
    
    func testGetRandomKeyReturnThirdGroupFromUUID() throws {
        
        let fakeUUID = "b6815296-04b3-11ee-be56-0242ac120002"
        let randomKey = getRandomKey(randomUUID: fakeUUID)
        
        let expectdRandomKey = "11ee"
        
        XCTAssertEqual(expectdRandomKey, randomKey)

    }
    
    func testGetTimestampBase36ReturnTheSameDateAfterConversion() throws {
        
        let expectedDate = Date()
        let timeBase36 = getTimestampBase36(timeInMilliseconds: expectedDate.millisecondsReferenceDate)
        let convertedDate = Date(milliseconds: Int64(timeBase36!, radix: 36)!)
        
        XCTAssertEqualWithAccuracy(expectedDate.timeIntervalSinceReferenceDate, convertedDate.timeIntervalSinceReferenceDate, accuracy: 0.001)

    }

}
