// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrustlySDK",
    platforms: [.iOS(.v12)],
    products: [


        .library(
            name: "TrustlySDK",
            targets: ["TrustlySDK"]),
    ],
    targets: [
        .target(name: "TrustlySDK",
            path: "Sources",
            resources: [.copy("TrustlySDK/PrivacyInfo.xcprivacy")]
        ),
    ]
)
