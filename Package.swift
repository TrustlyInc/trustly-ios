// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrustlySDK",
    platforms: [.iOS(.v16)],
    products: [


        .library(
            name: "TrustlySDK",
            targets: ["TrustlySDK"]),
    ],
    targets: [
        .target(
            name: "TrustlySDK",
            dependencies: []),
    ]
)
