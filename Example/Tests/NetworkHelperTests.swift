//
//  NetworkHelperTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 16/07/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class NetworkHelperTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        
    }

    func testIsLocalEnvironment() throws {
        
        var expectedResult = true
        
        var result = isLocalUrl(environment: "local")

        XCTAssertEqual(expectedResult, result)
        
        expectedResult = false
        
        result = isLocalUrl(environment: "sandbox")

        XCTAssertEqual(expectedResult, result)
    }
    
    func testThrowsInvalidUrlError() throws {
        
        XCTAssertThrowsError(try buildEnvironment(
            function: "widget",
            environment: "<sandbox>",
            localUrl: "",
            paymentType: "Retrieval",
            build: "3.2.2"
        )) { error in
            XCTAssertEqual(error as! NetworkError, NetworkError.invalidUrl)
        }
    }
    
    func testBuildLocalEnvironment() throws {
        
        let environment = try buildEnvironment(
            function: "widget",
            environment: "local",
            localUrl: "192.168.0.1",
            paymentType: "Retrieval",
            build: "3.2.2"
        )
        
        let expectedIsLocal = true
        let expectedUrl = URL(string: "http://192.168.0.1:8000/start/selectBank/widget?v=3.2.2-ios-sdk")!
        
        XCTAssertEqual(expectedIsLocal, environment.isLocal)
        XCTAssertEqual(expectedUrl, environment.url)
    }
    
    func testBuildLocalHostEnvironment() throws {
        
        let environment = try buildEnvironment(
            function: "widget",
            environment: "local",
            localUrl: "",
            paymentType: "Retrieval",
            build: "3.2.2"
        )
        
        let expectedIsLocal = true
        let expectedUrl = URL(string: "http://localhost:8000/start/selectBank/widget?v=3.2.2-ios-sdk")!
        
        XCTAssertEqual(expectedIsLocal, environment.isLocal)
        XCTAssertEqual(expectedUrl, environment.url)
    }
    
    func testBuildDynamicEnvironment() throws {
        
        let environment = try buildEnvironment(
            function: "widget",
            environment: "dynamic",
            localUrl: "trustlyTest",
            paymentType: "Retrieval",
            build: "3.2.2"
        )
        
        let expectedIsLocal = false
        let expectedUrl = URL(string: "https://trustlyTest.int.trustly.one/start/selectBank/widget?v=3.2.2-ios-sdk")!
        
        XCTAssertEqual(expectedIsLocal, environment.isLocal)
        XCTAssertEqual(expectedUrl, environment.url)
    }
    
    func testBuildSandboxEnvironment() throws {
        
        let environment = try buildEnvironment(
            function: "widget",
            environment: "sandbox",
            localUrl: "",
            paymentType: "Retrieval",
            build: "3.2.2"
        )
        
        let expectedIsLocal = false
        let expectedUrl = URL(string: "https://sandbox.paywithmybank.com/start/selectBank/widget?v=3.2.2-ios-sdk")!
        
        XCTAssertEqual(expectedIsLocal, environment.isLocal)
        XCTAssertEqual(expectedUrl, environment.url)
    }
    
    func testBuildProductionEnvironment() throws {
        
        let environment = try buildEnvironment(
            function: "widget",
            environment: "",
            localUrl: "",
            paymentType: "Retrieval",
            build: "3.2.2"
        )
        
        let expectedIsLocal = false
        let expectedUrl = URL(string: "https://paywithmybank.com/start/selectBank/widget?v=3.2.2-ios-sdk")!
        
        XCTAssertEqual(expectedIsLocal, environment.isLocal)
        XCTAssertEqual(expectedUrl, environment.url)
    }
}
