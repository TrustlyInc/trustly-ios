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
        
        let urlBuiltForWidget = try? URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String])
        
        XCTAssertEqual(expectedUrlForWidget, urlBuiltForWidget)
        
        let urlBuiltForIndex = try? URLUtils.buildEndpointUrl(function: "index", establishData: self.establishData as! [String : String])
        
        XCTAssertEqual(expectedUrlForIndex, urlBuiltForIndex)
        
    }
    
    func testBuildEndpointUrlSubdomainEnvironment() throws {
        
        self.establishData["env"] = "sandbox"
        
        let expectedUrl = "https://sandbox.\(Constants.baseDomain)/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        
        let urlBuiltForWidget = try? URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String])
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
        
    }
    
    func testBuildEndpointUrlLocalEnvironmentWithOutLocalUrl() throws {
        
        self.establishData["env"] = "local"
        
        XCTAssertThrowsError(try URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String])) { error in
            XCTAssertEqual(error as! TrustlyURLError, TrustlyURLError.missingLocalUrl)
        }
    }
    
    func testBuildEndpointUrlLocalEnvironment() throws {
        
        self.establishData["env"] = "local"
        self.establishData["localUrl"] = "192.168.0.15:8000"
        
        XCTAssertNoThrow(try URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String]))
        
        let expectedUrl = "http://192.168.0.15:8000/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        
        let urlBuiltForWidget = try? URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String])
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
        
    }
    
    func testBuildEndpointUrlIsLocalEnvironmentFlag() throws {
        
        self.establishData["env"] = "local"
        self.establishData["localUrl"] = "192.168.0.15:8000"
        
        XCTAssertNoThrow(try URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String]))
        
        let expectedUrl = "http://192.168.0.15:8000/start/selectBank/widget?v=\(Constants.buildSDK)-ios-sdk"

        
        let urlBuiltForWidget = try? URLUtils.buildEndpointUrl(function: "widget", establishData: self.establishData as! [String : String])
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
        XCTAssertEqual(true, URLUtils.isLocalEnvironment)
        
    }

}

