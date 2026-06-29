//
//  LightboxContainerView.swift
//  ExampleAppSwiftUI
//

import SwiftUI

struct LightboxContainerView: View {

    @Environment(TrustlyViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 24) {
            Text("Lightbox Payment")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the button below to start a Trustly Lightbox payment.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Open Lightbox") {
                viewModel.isLightboxPresented = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Lightbox")
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $viewModel.isLightboxPresented) {
            TrustlyLightboxRepresentable(
                establishData: viewModel.establishData,
                delegate: viewModel
            )
            .ignoresSafeArea()
        }
    }
}
