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
    
    func testThrowsInvalidUrlError() throws {
        
        XCTAssertThrowsError(try buildEnvironment(
            resourceUrl: .widget,
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
            resourceUrl: .widget,
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
            resourceUrl: .widget,
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
    
    func testBuildLocalHostEnvironmentFrontendPort() throws {
        
        let environment = try buildEnvironment(
            resourceUrl: .setup,
            environment: "local",
            localUrl: "",
            paymentType: "Retrieval",
            build: "3.2.2",
            path: .mobile
        )
        
        let expectedIsLocal = true
        let expectedUrl = URL(string: "http://localhost:10000/frontend/mobile/setup")!
        
        XCTAssertEqual(expectedIsLocal, environment.isLocal)
        XCTAssertEqual(expectedUrl, environment.url)
    }
    
    func testBuildDynamicEnvironment() throws {
        
        let environment = try buildEnvironment(
            resourceUrl: .widget,
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
            resourceUrl: .widget,
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
            resourceUrl: .widget,
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
