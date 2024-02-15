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
    
    override func setUp() {
        super.setUp()
        
        self.establishData = ["accessId": "A48B73F694C4C8EE6306",
                                "customer.address.country" : "US",
                                "customer.address.street" : "ABC Avenue",
                                "metadata.urlScheme": "demoapp://"]
        
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
    
        
        XCTAssertEqual(expectedEstablishData, jsonString)
                
    }

}
