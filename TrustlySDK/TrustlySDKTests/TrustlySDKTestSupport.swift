//
//  TrustlySDKTestSupport.swift
//  TrustlySDKTests
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import XCTest
@testable import TrustlySDK

class TrustlySDKTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        resetPersistentState()
    }

    override func tearDown() {
        resetPersistentState()
        super.tearDown()
    }

    func makeBaseEstablishData() -> [AnyHashable: Any] {
        [
            "accessId": "access-id",
            "merchantId": "merchant-id",
            "merchantReference": "merchant-reference",
            "requestSignature": "signed-request",
            "customer.address.country": "US",
            "metadata.lang": "en",
            "env": "sandbox",
            "paymentType": Constants.paymentTypeVerification
        ]
    }

    func resetPersistentState() {
        let keys = [
            StorageHelper.session_cid.rawValue,
            StorageHelper.settings.rawValue,
            Constants.repositoryGRP,
            Constants.repositoryTrustlyContext
        ]

        keys.forEach(UserDefaults.standard.removeObject(forKey:))
    }

    func privateProperty<T>(named name: String, from object: Any) -> T? {
        var mirror: Mirror? = Mirror(reflecting: object)

        while let currentMirror = mirror {
            if let value = currentMirror.children.first(where: { $0.label == name })?.value as? T {
                return value
            }
            mirror = currentMirror.superclassMirror
        }

        return nil
    }
}

final class TrustlySDKProtocolSpy: TrustlySDKProtocol {
    var externalUrlHandler: TrustlyViewCallback?
    var changeEvents: [(name: String, details: [AnyHashable: Any])] = []
    var bankSelections: [[AnyHashable: Any]] = []
    var returnParameters: [[AnyHashable: Any]] = []
    var cancelParameters: [[AnyHashable: Any]] = []

    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) {
        externalUrlHandler = onExternalUrl
    }

    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable : Any]) {
        changeEvents.append((eventName, eventDetails))
    }

    func onBankSelected(data: [AnyHashable : Any]) {
        bankSelections.append(data)
    }

    func onReturn(_ returnParameters: [AnyHashable : Any]) {
        self.returnParameters.append(returnParameters)
    }

    func onCancel(_ returnParameters: [AnyHashable : Any]) {
        cancelParameters.append(returnParameters)
    }
}

final class FailingURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
    }

    override func stopLoading() {
    }
}