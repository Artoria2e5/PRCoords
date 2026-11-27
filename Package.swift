// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "prcoords",
    products: [
        .library(name: "PRCoords", targets: ["PRCoords"]),
        .executable(name: "vecs", targets: ["vecs"]),
    ],
    targets: [
        .target(name: "PRCoords", path: "swift/Sources/PRCoords",
                swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
        .executableTarget(name: "vecs", dependencies: ["PRCoords"], path: "swift/Sources/vecs",
                swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
    ],
    swiftLanguageVersions: [.v5]
)
