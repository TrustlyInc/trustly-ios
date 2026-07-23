//
//  TrustlySDKStringExtensionTests.swift
//  TrustlySDK
//
//  Created by Andre Guedes on 23/07/26.
//

import XCTest
@testable import TrustlySDK

final class TrustlySDKStringExtensionTests: TrustlySDKTestCase {
    
    // MARK: - Core Requirement Tests
        
    /// Test that email addresses encode @ to %40 and do NOT double-encode (%2540)
    func testEmailEncoding() {
        let rawEmail = "user@example.com"
        XCTAssertEqual(rawEmail.urlEncodedForm(), "user%40example.com")
    }

    /// Test that pre-encoded emails are handled safely without double-encoding
    func testPreEncodedEmailHandling() {
        let preEncodedEmail = "user%40example.com"
        XCTAssertEqual(preEncodedEmail.urlEncodedForm(), "user%40example.com")
    }

    /// Test that phone numbers encode + to %2B
    func testPhoneEncoding() {
        let rawPhone = "+15551234567"
        XCTAssertEqual(rawPhone.urlEncodedForm(), "%2B15551234567")
    }

    /// Test that spaces are converted to '+' (Form URL encoding standard)
    func testSpacesConvertedToPlus() {
        let input = "iOS SDK Demo"
        XCTAssertEqual(input.urlEncodedForm(), "iOS+SDK+Demo")
    }

    // MARK: - Cryptographic & Special Character Tests

    /// Test Base64 signature encoding (+, /, = symbols)
    func testSignatureEncoding() {
        let rawSignature = "aBC123xyz+/KeyHash="
        let expected = "aBC123xyz%2B%2FKeyHash%3D"
        XCTAssertEqual(rawSignature.urlEncodedForm(), expected)
    }

    /// Test device/context strings with colons
    func testColonEncoding() {
        let input = "mobile:ios:native"
        XCTAssertEqual(input.urlEncodedForm(), "mobile%3Aios%3Anative")
    }

    /// Test custom scheme URLs (slashes and colons)
    func testCustomSchemeEncoding() {
        let input = "app://callback"
        XCTAssertEqual(input.urlEncodedForm(), "app%3A%2F%2Fcallback")
    }

    // MARK: - Safe Character Preservation Tests

    /// Unreserved characters (- _ . *) should remain unencoded
    func testUnreservedCharactersArePreserved() {
        let input = "abc-123_XYZ.test*1"
        XCTAssertEqual(input.urlEncodedForm(), "abc-123_XYZ.test*1")
    }

    // MARK: - Dictionary & Query String Integration Test

    /// Test full query string generation from an AnyHashable dictionary
    func testAnyHashableDictionaryQueryBuilding() {
        let params: [AnyHashable: AnyHashable] = [
            "customer.email": "user@example.com",
            "customer.phone": "+15551234567",
            "customer.name": "iOS SDK Demo",
            "version": 2
        ]

        let queryPairs: [String] = params.compactMap { key, value in
            let k = "\(key)".urlEncodedForm()
            let v = "\(value)".urlEncodedForm()
            return "\(k)=\(v)"
        }

        // Verify key encoded outputs exist within the query set
        XCTAssertTrue(queryPairs.contains("customer.email=user%40example.com"))
        XCTAssertTrue(queryPairs.contains("customer.phone=%2B15551234567"))
        XCTAssertTrue(queryPairs.contains("customer.name=iOS+SDK+Demo"))
        XCTAssertTrue(queryPairs.contains("version=2"))
    }
    
    // MARK: - Safe / Plain Text Tests (No Encoding Needed)
        
    /// Test that standard alphanumeric strings pass through untouched without any percent-encoding modifications
    func testAlphanumericStringsRequireNoEncoding() {
        let plainInput = "Alphanumeric123"
        XCTAssertEqual(plainInput.urlEncodedForm(), "Alphanumeric123")
    }

    /// Test that integers converted to string remain completely unmodified
    func testNumericStringsRequireNoEncoding() {
        let numericInput = "1175"
        XCTAssertEqual(numericInput.urlEncodedForm(), "1175")
    }
    
    /// Test that non-ASCII characters are percent-encoded (UTF-8) to remain safe for use in `percentEncodedQueryItems`
    func testNonASCIICharactersArePercentEncoded() {
        let input = "José"
        XCTAssertEqual(input.urlEncodedForm(), "Jos%C3%A9")
    }

    // MARK: - URLComponents Integration Tests (No Double-Encoding)

    /// Verifies that assigning pre-encoded items to `percentEncodedQueryItems`
    /// DOES NOT perform additional percent-encoding (prevents %2540)
    func testPercentEncodedQueryItemsDoesNotDoubleEncode() {
        var components = URLComponents(string: "https://example.com/widget")!
        
        // Input is pre-encoded via custom urlEncodedForm()
        let preEncodedEmail = "user@example.com".urlEncodedForm() // Output: "user%40example.com"
        
        let queryItems = [
            URLQueryItem(name: "customer.email", value: preEncodedEmail)
        ]
        
        // CRITICAL: Assigning to percentEncodedQueryItems prevents double-encoding
        components.percentEncodedQueryItems = queryItems
        
        let urlString = components.url?.absoluteString ?? ""
        
        // MUST contain %40 and MUST NOT contain %2540
        XCTAssertTrue(urlString.contains("customer.email=user%40example.com"))
        XCTAssertFalse(urlString.contains("customer.email=user%2540example.com"))
    }

    /// Contrasting test showing how using standard `queryItems` with pre-encoded input
    /// causes unwanted double-encoding (Failure case verification)
    func testQueryItemsCausesDoubleEncodingTrap() {
        var components = URLComponents(string: "https://example.com/widget")!
        
        // Input is already encoded
        let preEncodedEmail = "user%40example.com"
        
        let queryItems = [
            URLQueryItem(name: "customer.email", value: preEncodedEmail)
        ]
        
        // WRONG: Standard queryItems treats % as a literal character and encodes it to %25
        components.queryItems = queryItems
        
        let urlString = components.url?.absoluteString ?? ""
        
        // Demonstrates the double-encoding bug
        XCTAssertTrue(urlString.contains("customer.email=user%2540example.com"))
    }
    
}
