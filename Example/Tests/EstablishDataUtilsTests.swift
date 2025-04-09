//
//  EstablishDataUtilsTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 15/02/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class EstablishDataUtilsTests: XCTestCase {
    
    var establishData:Dictionary<String, String> = [:]
    var urlWithParamters: String = ""
    
    override func setUp() {
        super.setUp()
        
        self.establishData = ["accessId": "A48B73F694C4C8EE6306",
                                "customer.address.country" : "US",
                                "customer.address.street" : "ABC Avenue",
                                "metadata.urlScheme": "demoapp://"]
        
        self.urlWithParamters = "demoapp://?transactionId=1003151780&transactionType=1&merchantReference=g:cac73df7-52b4-47d7-89d3-9628d4cfb65e&payment.paymentProvider.type=1&requestSignature=E0rbmsl4KOORibvsHoDvfqIqlaQ%3D"
        
    }
    
    func testNormalizeDotNotation() throws {
        
        let expectedEstablishData: [String : AnyHashable] = [
            "accessId": "A48B73F694C4C8EE6306",
            "customer" : ["address": ["country": "US", "street": "ABC Avenue"]],
            "metadata" : ["urlScheme": "demoapp://"]
        ]
        
        let normalizedEstablish = EstablishDataUtils.normalizeEstablishWithDotNotation(establish: self.establishData)
        
        XCTAssertEqual(expectedEstablishData, normalizedEstablish)
                
    }
// TODO: This test was commented, because for now we will not normalize the return
//    func testConvertUrlWithParameterToNormalizedEstablish() throws {
//        
//        let expectedEstablishData: [String : AnyHashable] = [
//            "transactionId": "1003151780",
//            "transactionType": "1",
//            "merchantReference": "g:cac73df7-52b4-47d7-89d3-9628d4cfb65e",
//            "payment": ["paymentProvider": ["type" : "1"]],
//            "requestSignature": "E0rbmsl4KOORibvsHoDvfqIqlaQ%3D",
//            "url": self.urlWithParamters
//        ]
//        
//        let normalizedEstablish = EstablishDataUtils.buildEstablishFrom(urlWithParameters: self.urlWithParamters)
//        
//        XCTAssertEqual(expectedEstablishData, normalizedEstablish)
//                
//    }
    
    func testExtractUrlSchemeFrom() throws {
        
        let expectedUrlScheme = "demoapp"
        
        let establishData: [String : AnyHashable] = [
            "accessId": "A48B73F694C4C8EE6306",
            "customer" : ["address": ["country": "US", "street": "ABC Avenue"]],
            "metadata.urlScheme" : "demoapp://"
        ]
        
        let urlScheme = EstablishDataUtils.extractUrlSchemeFrom(establishData)
        
        XCTAssertEqual(expectedUrlScheme, urlScheme)
    }
    
    func testExtractUrlSchemeFromEmptyEstablish() throws {
        
        let expectedUrlScheme = ""
        
        let establishData: [String : AnyHashable] = [:]
        
        let urlScheme = EstablishDataUtils.extractUrlSchemeFrom(establishData)
        
        XCTAssertEqual(expectedUrlScheme, urlScheme)
    }

}
