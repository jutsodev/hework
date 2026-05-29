// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HeWork",
    platforms: [.iOS(.v17)],
    products: [.library(name: "HeWork", targets: ["HeWork"])],
    targets: [
        .target(name: "HeWork", path: "HeWork/HeWork")
    ]
)
