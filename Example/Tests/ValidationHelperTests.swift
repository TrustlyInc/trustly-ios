//
//  ValidationHelperTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 05/07/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class ValidationHelperTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testRecognize400Error() throws {
        
        let content = "Error 404 not found"
        
        let expectdResult = true
        
        let matches = ValidationHelper.findMatchesForErrorCode(content: content)
        
        let isErrorCodePage = ValidationHelper.isErrorCodePage(matches: matches, content: content)

        XCTAssertEqual(expectdResult, isErrorCodePage)
    }
    
    func testRecognize500Error() throws {
        
        let content = "Internal error server 500"
        
        let expectdResult = true
        
        let matches = ValidationHelper.findMatchesForErrorCode(content: content)
        
        let isErrorCodePage = ValidationHelper.isErrorCodePage(matches: matches, content: content)

        XCTAssertEqual(expectdResult, isErrorCodePage)
    }
    
    func testRecognizeIsNotErrorPage() throws {
        
        let content = "Regular content"
        
        let expectdResult = false
        
        let matches = ValidationHelper.findMatchesForErrorCode(content: content)
        
        let isErrorCodePage = ValidationHelper.isErrorCodePage(matches: matches, content: content)

        XCTAssertEqual(expectdResult, isErrorCodePage)
    }

    func testMatchErrorCodes() throws {
        
        let content = "Internal error server 500"
        
        let expectdResult = 1
        
        let matches = ValidationHelper.findMatchesForErrorCode(content: content)

        XCTAssertEqual(expectdResult, matches.count)
    }
}
