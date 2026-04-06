//
//  WidgetContainerView.swift
//  ExampleAppSwiftUI
//

import SwiftUI

struct WidgetContainerView: View {

    @Environment(TrustlyViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 16) {
            Text("Select your bank below to proceed.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TrustlyWidgetRepresentable(
                establishData: viewModel.establishData,
                delegate: viewModel
            )
            .frame(maxWidth: .infinity)
            .frame(height: 500)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .navigationTitle("Bank Selection")
        .sheet(isPresented: $viewModel.isLightboxPresented) {
            TrustlyLightboxRepresentable(
                establishData: viewModel.establishData,
                delegate: viewModel
            )
            .ignoresSafeArea()
        }
    }
}
