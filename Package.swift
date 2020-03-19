// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Parser",
    products: [
        .library(
            name: "Parser",
            targets: ["Parser"]
        ),
    ],
    targets: [
        .target(
            name: "Parser",
            dependencies: []
        ),
        .testTarget(
            name: "ParserTests",
            dependencies: ["Parser"]
        ),
    ]
)
