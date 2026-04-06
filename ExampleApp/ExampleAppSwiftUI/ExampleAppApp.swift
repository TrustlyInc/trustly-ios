//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import SwiftUI
import TrustlySDK

@main
struct ExampleAppApp: App {

    @State private var viewModel = TrustlyViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .onOpenURL { url in
                    if url.absoluteString == "demoapp://" {
                        NotificationCenter.default.post(name: .trustlyCloseWebview, object: nil)
                    }
                }
        }
    }
}
