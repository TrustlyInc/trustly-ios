//
//  TrustlyCommonFunctionsTests.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 19/02/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class TrustlyCommonFunctionsTests: XCTestCase {

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()

        UserDefaults.standard.removeObject(forKey: Constants.repositoryTrustlyContext)
        UserDefaults.standard.removeObject(forKey: Constants.repositoryGRP)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Constants.repositoryTrustlyContext)
        UserDefaults.standard.removeObject(forKey: Constants.repositoryGRP)
        super.tearDown()
    }

    // MARK: - Tests for getTrustlyContext
    func testGetTrustlyContext_WhenEmpty_ShouldReturnEmptyString() {
        let context = getTrustlyContext()
        
        XCTAssertEqual(context, "")
    }

    func testGetTrustlyContext_WhenHasValue_ShouldReturnCorrectValue() {

        let expectedValue = "mock_context"
        LocalStorage.save(expectedValue, forKey: Constants.repositoryTrustlyContext)
        

        let context = getTrustlyContext()
        

        XCTAssertEqual(context, expectedValue)
    }

    // MARK: - Tests for getGrp
    func testGetGrp_WhenEmpty_ShouldGenerateAndReturnNewValue() {

        let grp = getGrp()
        
        XCTAssertNotNil(grp)
        XCTAssertFalse(grp.isEmpty)
        
        let isNumber = Int(grp) != nil
        XCTAssertTrue(isNumber, "GRP should be a number")
    }

    func testGetGrp_WhenHasValue_ShouldNotGenerateNewOne() {
        // Given
        let existingGrp = "42"
        LocalStorage.save(existingGrp, forKey: Constants.repositoryGRP)
        
        // When
        let grp = getGrp()
        
        // Then
        XCTAssertEqual(grp, existingGrp)
    }

    // MARK: - Tests for generateGrp
    func testGenerateGrp_ShouldReturnNumberWithinRange() {
        // When
        let grp = generateGrp()
        let grpInt = Int(grp)
        
        // Then
        XCTAssertNotNil(grpInt)
        if let value = grpInt {
            XCTAssertTrue(value >= 0 && value < 100, "GRP should be between 0 to 99")
        }
    }
}
