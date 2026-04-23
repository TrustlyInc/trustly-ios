//
//  TrustlyWidgetRepresentable.swift
//  ExampleAppSwiftUI
//

import SwiftUI
import TrustlySDK

struct TrustlyWidgetRepresentable: UIViewControllerRepresentable {

    let establishData: [AnyHashable: Any]
    weak var delegate: TrustlySDKProtocol?

    func makeUIViewController(context: Context) -> WidgetViewController {
        let viewController = WidgetViewController(establishData: establishData)
        viewController.delegate = delegate
        return viewController
    }

    func updateUIViewController(_ uiViewController: WidgetViewController, context: Context) {}
}
