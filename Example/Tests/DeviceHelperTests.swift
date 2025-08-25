//
//  DeviceHelperTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 01/04/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class DeviceHelperTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        
    }

    func testDeviceModel() throws {
        XCTAssertEqual("arm64", DeviceHelper.deviceModel())
    }

    func testSystemName() throws {
        XCTAssertEqual("iOS", DeviceHelper.systemName())
    }

    func testSystemVersion() throws {
        XCTAssertEqual(UIDevice.current.systemVersion, DeviceHelper.systemVersion())
    }

    func testMerchantAppVersion() throws {
        XCTAssertEqual("1.0", DeviceHelper.merchantAppVersion())
    }

    func testMerchantAppBuildNumber() throws {
        XCTAssertEqual("1", DeviceHelper.merchantAppBuildNumber())
    }
}
