//
//  TrustlySDKControllerTests.swift
//  TrustlySDKTests
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import XCTest
import UIKit
@preconcurrency import WebKit
@testable import TrustlySDK

final class TrustlySDKControllerTests: TrustlySDKTestCase {

    @MainActor
    func testLightBoxViewControllerInitializesWKWebViewOnMainActor() {
        let viewController = LightBoxViewController(establishData: makeBaseEstablishData())

        viewController.initWebView()

        let webViewManager: WebViewManager? = privateProperty(named: "webViewManager", from: viewController)
        let mainWebView: WKWebView? = privateProperty(named: "mainWebView", from: viewController)

        XCTAssertNotNil(webViewManager)
        XCTAssertNotNil(mainWebView)
        XCTAssertTrue(viewController.view.subviews.contains { $0 is WKWebView })
    }

    @MainActor
    func testWidgetViewControllerInitializesWKWebViewOnMainActor() {
        let viewController = WidgetViewController(establishData: makeBaseEstablishData())

        viewController.initWebView()

        let webViewManager: WebViewManager? = privateProperty(named: "webViewManager", from: viewController)
        let mainWebView: WKWebView? = privateProperty(named: "mainWebView", from: viewController)

        XCTAssertNotNil(webViewManager)
        XCTAssertNotNil(mainWebView)
        XCTAssertTrue(viewController.view.subviews.contains { $0 is WKWebView })
    }

    @MainActor
    func testLightBoxViewControllerForwardsDelegateCallbacksAndStoresTrustlyContext() {
        URLProtocol.registerClass(FailingURLProtocol.self)
        defer { URLProtocol.unregisterClass(FailingURLProtocol.self) }

        let cachedSettings = TrustlySettings(
            settings: Settings(integrationStrategy: Constants.lightboxContentWebview),
            createdDateTime: Date()
        )
        saveData(cachedSettings, keyStorage: .settings)

        let delegate = TrustlySDKProtocolSpy()
        let viewController = LightBoxViewController(establishData: makeBaseEstablishData())
        viewController.delegate = delegate

        viewController.loadViewIfNeeded()

        let webViewManager: WebViewManager? = privateProperty(named: "webViewManager", from: viewController)
        webViewManager?.returnHandler?(["status": "success", "trustlyContext": "stored-context"])
        webViewManager?.cancelHandler?(["reason": "cancelled"])
        webViewManager?.notifyEvent("widget", "load")

        XCTAssertEqual(delegate.returnParameters.first?["status"] as? String, "success")
        XCTAssertEqual(delegate.cancelParameters.first?["reason"] as? String, "cancelled")
        XCTAssertEqual(delegate.changeEvents.first?.name, "event")
        XCTAssertEqual(delegate.changeEvents.first?.details["page"] as? String, "widget")
        XCTAssertEqual(LocalStorage.getFrom(key: Constants.repositoryTrustlyContext), "stored-context")
    }

    @MainActor
    func testLightBoxViewControllerRemovesTrustlyContextFromReturnCallbackParameters() {
        URLProtocol.registerClass(FailingURLProtocol.self)
        defer { URLProtocol.unregisterClass(FailingURLProtocol.self) }

        let delegate = TrustlySDKProtocolSpy()
        let viewController = LightBoxViewController(establishData: makeBaseEstablishData())
        viewController.delegate = delegate

        viewController.loadViewIfNeeded()

        let webViewManager: WebViewManager? = privateProperty(named: "webViewManager", from: viewController)
        webViewManager?.returnHandler?(["status": "success", Constants.trustlyContext: "stored-context"])

        XCTAssertEqual(delegate.returnParameters.count, 1)
        XCTAssertEqual(delegate.returnParameters.first?["status"] as? String, "success")
        XCTAssertNil(delegate.returnParameters.first?[Constants.trustlyContext])
        XCTAssertEqual(LocalStorage.getFrom(key: Constants.repositoryTrustlyContext), "stored-context")
    }

    @MainActor
    func testLightBoxViewControllerRemovesTrustlyContextFromCancelCallbackParameters() {
        URLProtocol.registerClass(FailingURLProtocol.self)
        defer { URLProtocol.unregisterClass(FailingURLProtocol.self) }

        let delegate = TrustlySDKProtocolSpy()
        let viewController = LightBoxViewController(establishData: makeBaseEstablishData())
        viewController.delegate = delegate

        viewController.loadViewIfNeeded()

        let webViewManager: WebViewManager? = privateProperty(named: "webViewManager", from: viewController)
        webViewManager?.cancelHandler?(["reason": "cancelled", Constants.trustlyContext: "stored-context"])

        XCTAssertEqual(delegate.cancelParameters.count, 1)
        XCTAssertEqual(delegate.cancelParameters.first?["reason"] as? String, "cancelled")
        XCTAssertNil(delegate.cancelParameters.first?[Constants.trustlyContext])
        XCTAssertEqual(LocalStorage.getFrom(key: Constants.repositoryTrustlyContext), "stored-context")
    }

    @MainActor
    func testWidgetViewControllerForwardsBankSelectionToDelegate() {
        let delegate = TrustlySDKProtocolSpy()
        let viewController = WidgetViewController(establishData: makeBaseEstablishData())
        viewController.delegate = delegate

        viewController.loadViewIfNeeded()

        let webViewManager: WebViewManager? = privateProperty(named: "webViewManager", from: viewController)
        webViewManager?.bankSelectedHandler?(["paymentProviderId": "bank-1"])

        XCTAssertEqual(delegate.bankSelections.first?["paymentProviderId"] as? String, "bank-1")
    }
}