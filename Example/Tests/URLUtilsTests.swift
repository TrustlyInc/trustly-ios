//
//  URLUtilsTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 29/01/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class URLUtilsTests: XCTestCase {
    
    var establishData:Dictionary<AnyHashable,Any> = [:]
    
    override func setUp() {
        super.setUp()
        
        self.establishData = ["accessId": "A48B73F694C4C8EE6306",
                                "merchantId" : "110005514",
                                "currency" : "USD",
                                "amount" : "1.00",
                                "merchantReference" : "g:cac73df7-52b4-47d7-89d3-9628d4cfb65e",
                                "paymentType" : "Retrieval",
                                "returnUrl": "/returnUrl",
                                "cancelUrl": "/cancelUrl",
                                "requestSignature": "HT5mVOqBXa8ZlvgX2USmPeLns5o=",
                                "customer.name": "John IOS",
                                "customer.address.country": "US",
                                "metadata.urlScheme": "demoapp://",
                                "description": "First Data Mobile Test"]
    }
    
    func testBuildEndpointUrlProdEnvironment() throws {
        
        let expectedUrlForWidget = "https://\(Constants.baseDomain)/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"
        let expectedUrlForIndex = "https://\(Constants.baseDomain)/start/selectBank/selectBank?v=\(Constants.buildSDK)-ios-sdk"
        
        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            build: Constants.buildSDK,
            isLocalUrl: false,
            environment: ""
        )
        
        XCTAssertEqual(expectedUrlForWidget, urlBuiltForWidget)
        
        let urlBuiltForIndex = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.selectBank.rawValue,
            build: Constants.buildSDK,
            isLocalUrl: false,
            environment: ""
        )
     
        XCTAssertEqual(expectedUrlForIndex, urlBuiltForIndex)
        
    }
    
    func testBuildEndpointUrlSubdomainEnvironment() throws {
        
        let expectedUrl = "https://sandbox.\(Constants.baseDomain)/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "sandbox",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            build: Constants.buildSDK,
            isLocalUrl: false,
            environment: ""
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlLocalEnvironmentWithIP() throws {
        
        let expectedUrl = "http://192.168.0.15:8000/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "192.168.0.15",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            build: Constants.buildSDK,
            isLocalUrl: true,
            environment: "local"
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlLocalEnvironmentWithoutIP() throws {
        
        let expectedUrl = "http://localhost:8000/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            build: Constants.buildSDK,
            isLocalUrl: true,
            environment: "local"
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlDynamic() throws {
        
        let expectedUrl = "https://dynamicEnv.int.trustly.one/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "dynamicEnv",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            build: Constants.buildSDK,
            isLocalUrl: false,
            environment: "dynamic"
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testIsLocalEnvironment() throws {
        
        var expectedResult = true
        
        var result = URLUtils.isLocalUrl(environment: "local")

        XCTAssertEqual(expectedResult, result)
        
        expectedResult = false
        
        result = URLUtils.isLocalUrl(environment: "sandbox")

        XCTAssertEqual(expectedResult, result)
    }
    
    func testUrlEncoded() throws {
        
        let data:[AnyHashable : Any] = [
            "param1": "\nvalue1"
        ]
        
        let expectedResult = "param1=%0Avalue1"
        let result = URLUtils.urlEncoded(data)
        
        XCTAssertEqual(expectedResult, result)
    }
    
    func testUrlDecoded() throws {
        
        let content = "%0Avalue1"
        
        let result = URLUtils.urlDecode(content)
        
        let expectedResult = "\nvalue1"
        
        XCTAssertEqual(expectedResult, result)
    }

}

