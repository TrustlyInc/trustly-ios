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
        
        self.establishData = ["accessId": "FakeAccessId",
                                "merchantId" : "8827389273"]
        
    }

    
    func testConvertDictionaryToJsonBase64AndJsonBase64ToDictionary() throws {
        
        let jsonStringBase64 = JSONUtils.getJsonBase64From(dictionary: self.establishData)!
        let newDictionary = JSONUtils.getDictionaryFrom(jsonStringBase64: jsonStringBase64)!
        
        XCTAssertEqual(newDictionary, self.establishData)
                
    }

}
