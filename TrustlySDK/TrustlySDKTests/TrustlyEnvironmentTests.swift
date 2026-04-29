import XCTest
@testable import TrustlySDK

class TrustlyEnvironmentTests: XCTestCase {

    func testProductionEnvironmentWithNilEnv() {
        let environment = TrustlyEnvironment(env: nil)
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://trustly.one")
    }

    func testProductionEnvironmentWithEmptyEnv() {
        let environment = TrustlyEnvironment(env: "")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://trustly.one")
    }

    func testProductionEnvironmentWithProd() {
        let environment = TrustlyEnvironment(env: "prod")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://trustly.one")
    }

    func testProductionEnvironmentWithProdUppercase() {
        let environment = TrustlyEnvironment(env: "PROD")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://trustly.one")
    }

    func testProductionEnvironmentWithProduction() {
        let environment = TrustlyEnvironment(env: "production")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://trustly.one")
    }

    func testDevelopmentEnvironment() {
        let environment = TrustlyEnvironment(env: "dev-667788")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://dev-667788.int.trustly.one")
    }

    func testLocalEnvironmentWithIPv4() {
        let environment = TrustlyEnvironment(env: "127.0.0.1")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "http://127.0.0.1")
    }

    func testLocalEnvironmentWithLocal() {
        let environment = TrustlyEnvironment(env: "local")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "http://localhost")
    }

    func testLocalEnvironmentWithLocalhost() {
        let environment = TrustlyEnvironment(env: "localhost")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "http://localhost")
    }

    func testCustomEnvironment() {
        let environment = TrustlyEnvironment(env: "staging")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://staging.trustly.one")
    }

    func testCustomEnvironmentWithOtherValue() {
        let environment = TrustlyEnvironment(env: "test")
        XCTAssertEqual(environment.baseURL.url?.absoluteString, "https://test.trustly.one")
    }
}
