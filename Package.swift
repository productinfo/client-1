// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Client",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Client",
            targets: ["Client"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", from: "3.2.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Client",
            dependencies: ["Result"]),
        .testTarget(
            name: "ClientTests",
            dependencies: ["Client"]),
    ]
)
