// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hummingbird-xct-async-http-client",
    products: [
        .library(name: "HBXCTAsyncHTTPClient",targets: ["HBXCTAsyncHTTPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "1.10.0"),
    ],
    targets: [
        .target(
            name: "HBXCTAsyncHTTPClient",
            dependencies: [
                .product(name: "HummingbirdXCT", package: "hummingbird"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(
            name: "HBXCTAsyncHTTPClientTests", 
            dependencies: ["HBXCTAsyncHTTPClient"]
        ),
    ]
)
