// swift-tools-version: 5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_voximplant",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "flutter-voximplant", targets: ["flutter_voximplant"])
    ],
    dependencies: [
        .package(url: "https://github.com/voximplant/ios-sdk-releases.git", .upToNextMinor(from: "2.56.0"))
    ],
    targets: [
        .target(
            name: "flutter_voximplant",
            dependencies: [
                .product(name: "VoximplantSDK", package: "ios-sdk-releases"),
            ],
            cSettings: [
                .headerSearchPath("include/flutter_voximplant")
            ]
        )
    ]
)
