//
//  LocalStorageTests.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 19/02/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import XCTest
@testable import TrustlySDK

final class LocalStorageTests: XCTestCase {

    let testKey = "test_key_item"
    let testValue = "test_value"

    override func setUp() {
        super.setUp()
        LocalStorage.userDefaults.removeObject(forKey: testKey)
    }

    override func tearDown() {
        LocalStorage.userDefaults.removeObject(forKey: testKey)
        super.tearDown()
    }

    func testSaveAndGet_ShouldReturnCorrectValue() {
        let valueToSave = testValue
        
        LocalStorage.save(valueToSave, forKey: testKey)
        let retrievedValue = LocalStorage.getFrom(key: testKey)
        
        XCTAssertEqual(retrievedValue, valueToSave)
    }

    func testGetFrom_WithEmptyKey_ShouldReturnDefaultValue() {
        let defaultValue = "fallback"

        let retrievedValue = LocalStorage.getFrom(key: "non_existent_key", defaultValue: defaultValue)
        
        XCTAssertEqual(retrievedValue, defaultValue, "Deve retornar o valor padrão quando a chave não existe.")
    }
    
    func testGetFrom_WithoutProvidingDefaultValue_ShouldReturnEmptyString() {
        let retrievedValue = LocalStorage.getFrom(key: "non_existent_key")
        
        XCTAssertEqual(retrievedValue, "", "O valor padrão default da assinatura deve ser uma String vazia.")
    }
}
