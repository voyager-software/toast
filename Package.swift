// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toast",
    platforms:
    [
       .iOS(.v13),
       .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Toast",
            targets: ["Toast"]),
    ],
    dependencies: [
        .package(url: "https://www.github.com/voyager-software/NVActivityIndicatorView", from: "5.2.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Toast",
            dependencies: [
                "NVActivityIndicatorView"
            ]),
        .testTarget(
            name: "ToastTests",
            dependencies: ["Toast"]),
    ]
)
