// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HumaneSpaceTab",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "SwitcherCore", targets: ["SwitcherCore"]),
        .library(name: "SystemPorts", targets: ["SystemPorts"]),
        .library(name: "SystemAdapters", targets: ["SystemAdapters"]),
        .library(name: "SwitcherUI", targets: ["SwitcherUI"]),
    ],
    targets: [
        .target(name: "SwitcherCore"),
        .target(name: "SystemPorts", dependencies: ["SwitcherCore"]),
        .target(name: "SystemAdapters", dependencies: ["SystemPorts"]),
        .target(name: "SwitcherUI", dependencies: ["SwitcherCore", "SystemPorts"]),
        .testTarget(name: "SwitcherCoreTests", dependencies: ["SwitcherCore"]),
        .testTarget(name: "SourceGuardTests"),
    ]
)
