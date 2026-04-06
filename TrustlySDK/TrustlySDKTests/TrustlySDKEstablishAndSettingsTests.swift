//
//  TrustlySDKEstablishAndSettingsTests.swift
//  TrustlySDKTests
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import XCTest
@testable import TrustlySDK

final class TrustlySDKEstablishAndSettingsTests: TrustlySDKTestCase {

    func testNormalizeEstablishWithDotNotationBuildsNestedDictionaries() {
        let establish: [String: AnyHashable] = [
            "merchantId": "merchant-id",
            "customer.address.country": "US",
            "customer.address.city": "NewYork",
            "metadata.flowType": "widget"
        ]

        let normalized = EstablishDataUtils.normalizeEstablishWithDotNotation(establish: establish)
        let customer = normalized["customer"] as? [String: AnyHashable]
        let address = customer?["address"] as? [String: AnyHashable]
        let metadata = normalized["metadata"] as? [String: AnyHashable]

        XCTAssertEqual(normalized["merchantId"] as? String, "merchant-id")
        XCTAssertEqual(address?["country"] as? String, "US")
        XCTAssertEqual(address?["city"] as? String, "NewYork")
        XCTAssertEqual(metadata?["flowType"] as? String, "widget")
    }

    func testBuildEstablishFromPreservesRawReturnParameters() {
        let url = "merchant://callback?paymentProviderId=bank-1&customer.address.country=US"

        let establish = EstablishDataUtils.buildEstablishFrom(urlWithParameters: url)

        XCTAssertEqual(establish["url"] as? String, url)
        XCTAssertEqual(establish["paymentProviderId"] as? String, "bank-1")
        XCTAssertEqual(establish["customer.address.country"] as? String, "US")
        XCTAssertNil(establish["customer"])
    }

    func testPrepareEstablishAddsSdkMetadataForWebviewFlow() {
        LocalStorage.save("grp-123", forKey: Constants.repositoryGRP)
        let establishData = makeBaseEstablishData()

        let prepared = EstablishDataUtils.prepareEstablish(
            establishData: establishData,
            cid: "cid-1",
            sessionCid: "session-1"
        )

        XCTAssertEqual(prepared["deviceType"] as? String, "mobile:ios:native")
        XCTAssertEqual(prepared["lang"] as? String, "en")
        XCTAssertEqual(prepared["metadata.sdkIOSVersion"] as? String, Constants.buildSDK)
        XCTAssertEqual(prepared["returnUrl"] as? String, Constants.returnURL)
        XCTAssertEqual(prepared["cancelUrl"] as? String, Constants.cancelURL)
        XCTAssertEqual(prepared["sessionCid"] as? String, "session-1")
        XCTAssertEqual(prepared["metadata.cid"] as? String, "cid-1")
        XCTAssertEqual(prepared["grp"] as? String, "grp-123")
        XCTAssertEqual(prepared["dynamicWidget"] as? String, "true")
        XCTAssertEqual(prepared["storage"] as? String, Constants.storageSupported)
        XCTAssertEqual(prepared["metadata.integrationContext"] as? String, Constants.inAppIntegrationContext)
        XCTAssertNil(prepared["widgetLoaded"])
    }

    func testPrepareEstablishConfiguresSecureBrowserFlowAndTrustlyContext() {
        LocalStorage.save("encoded-context", forKey: Constants.repositoryTrustlyContext)
        var establishData = makeBaseEstablishData()
        establishData["metadata.urlScheme"] = "merchant-app://callback"
        establishData["paymentProviderId"] = "bank-1"

        let prepared = EstablishDataUtils.prepareEstablish(
            establishData: establishData,
            cid: "cid-2",
            sessionCid: "session-2",
            inAppBrowser: true
        )

        XCTAssertEqual(prepared["returnUrl"] as? String, "merchant-app://callback")
        XCTAssertEqual(prepared["cancelUrl"] as? String, "merchant-app://callback")
        XCTAssertEqual(prepared["metadata.integrationContext"] as? String, Constants.secureBrowserIntegrationContext)
        XCTAssertEqual(prepared["metadata.trustlyContext"] as? String, "encoded-context")
        XCTAssertEqual(prepared["widgetLoaded"] as? String, "true")
    }

    func testExtractUrlSchemeReturnsCustomSchemeWithoutSeparator() {
        let establishData: [AnyHashable: Any] = ["metadata.urlScheme": "merchant-app://callback"]

        let scheme = EstablishDataUtils.extractUrlSchemeFrom(establishData)

        XCTAssertEqual(scheme, "merchant-app")
    }

    func testTrustlySettingsValidityUsesCacheWindow() {
        let validSettings = TrustlySettings(
            settings: Settings(integrationStrategy: Constants.lightboxContentWebview),
            createdDateTime: Date().addingTimeInterval(-60)
        )
        let expiredSettings = TrustlySettings(
            settings: Settings(integrationStrategy: Constants.lightboxContentWebview),
            createdDateTime: Date().addingTimeInterval(-1200)
        )

        XCTAssertTrue(validSettings.isValid())
        XCTAssertFalse(expiredSettings.isValid())
    }

    func testSettingsUserAgentMatchesIntegrationStrategy() {
        var webviewSettings = Settings(integrationStrategy: Constants.lightboxContentWebview)
        webviewSettings.webviewUserAgent = "CustomAgent/1.0"
        let inAppSettings = Settings(integrationStrategy: Constants.lightboxContentInApp)

        XCTAssertTrue(webviewSettings.isWebViewEnabled())
        XCTAssertFalse(webviewSettings.isInAppBrowserEnabled())
        XCTAssertEqual(webviewSettings.userAgent, "CustomAgent/1.0")
        XCTAssertTrue(inAppSettings.isInAppBrowserEnabled())
        XCTAssertFalse(inAppSettings.isWebViewEnabled())
        XCTAssertTrue(inAppSettings.userAgent.contains("InAppBrowser/1.0"))
    }
}