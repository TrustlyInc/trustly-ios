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
    
    override func setUp() {
        super.setUp()
        
    }
    
    func testBuildEndpointUrlProdEnvironment() throws {
        
        let expectedUrlForWidget = "https://\(Constants.baseDomain)/start/selectBank/widget"
        let expectedUrlForIndex = "https://\(Constants.baseDomain)/start/selectBank/selectBank"
        
        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            isLocalUrl: false,
            environment: ""
        )
        
        XCTAssertEqual(expectedUrlForWidget, urlBuiltForWidget)
        
        let urlBuiltForIndex = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.selectBank.rawValue,
            isLocalUrl: false,
            environment: ""
        )
     
        XCTAssertEqual(expectedUrlForIndex, urlBuiltForIndex)
        
    }
    
    func testBuildEndpointUrlSubdomainEnvironment() throws {
        
        let expectedUrl = "https://sandbox.\(Constants.baseDomain)/start/selectBank/widget"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "sandbox",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            isLocalUrl: false,
            environment: ""
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlLocalEnvironmentWithIP() throws {
        
        let expectedUrl = "http://192.168.0.15:8000/start/selectBank/widget"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "192.168.0.15",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            isLocalUrl: true,
            environment: "local"
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlLocalEnvironmentWithoutIP() throws {
        
        let expectedUrl = "http://localhost:8000/start/selectBank/widget"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "",
            subDomain: "",
            path: PathUrls.selectBank.rawValue,
            resource: ResourceUrls.widget.rawValue,
            isLocalUrl: true,
            environment: "local"
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlDynamic() throws {
        
        let expectedUrl = "https://dynamicEnv.int.trustly.one/frontend/mobile/setup"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "dynamicEnv",
            subDomain: "",
            path: PathUrls.mobile.rawValue,
            resource: ResourceUrls.setup.rawValue,
            isLocalUrl: false,
            environment: "dynamic"
        )
        
        XCTAssertEqual(expectedUrl, urlBuiltForWidget)
    }
    
    func testBuildEndpointUrlLocalFrontendPort() throws {
        
        let expectedUrl = "http://localhost:10000/frontend/mobile/setup"

        let urlBuiltForWidget = URLUtils.buildStringUrl(
            domain: "localhost",
            subDomain: "",
            path: PathUrls.mobile.rawValue,
            resource: ResourceUrls.setup.rawValue,
            isLocalUrl: true,
            environment: "local",
            port: Constants.portFrontend
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
    
    func testParametersForUrl() throws {
        
        guard let sampleUrl = URL(string: "https://www.example.com?param1=test1&param2=test2&param3=test3") else { return XCTFail() }
        
        let result = URLUtils.parametersForUrl(sampleUrl)

        XCTAssertEqual(sampleUrl.absoluteString, result["url"] as! String)
        XCTAssertEqual("test1", result["param1"] as! String)
        XCTAssertEqual("test2", result["param2"] as! String)
        XCTAssertEqual("test3", result["param3"] as! String)
    }

}
