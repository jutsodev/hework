// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HeWork",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "HeWork", targets: ["HeWork"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.20.0"),
    ],
    targets: [
        .target(
            name: "HeWork",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
