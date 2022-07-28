// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Cleevio",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "CleevioCore", targets: ["CleevioCore"]),
        .library(name: "CleevioRouters", targets: ["CleevioRouters"]),
        .library(name: "CleevioUI", targets: ["CleevioUI"])
    ],
    targets: [
        .target(name: "CleevioCore", path: "Cleevio/Classes/Core"),
        .target(name: "CleevioRouters", dependencies: ["CleevioCore"], path: "Cleevio/Classes/Routers"),
        .target(name: "CleevioUI", path: "Cleevio/Classes/UI")
    ]
)
