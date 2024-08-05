//
//  JsonUtilsTests.swift
//  TrustlySDK_Tests
//
//  Created by Marcos Rivereto on 08/02/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class JsonUtilsTests: XCTestCase {
    
    var establishData:Dictionary<String, String> = [:]
    
    override func setUp() {
        super.setUp()
        
        self.establishData = ["accessId": "A48B73F694C4C8EE6306",
                                "merchantId" : "110005514"]
        
    }

    
    func testBuildJsonBase64() throws {
        
        let jsonStringBase64 = JSONUtils.getJsonBase64From(dictionary: self.establishData)!
        let newDictionary = JSONUtils.getDictionaryFrom(jsonStringBase64: jsonStringBase64)!
        
        
        XCTAssertEqual(newDictionary, self.establishData)
                
    }


}
