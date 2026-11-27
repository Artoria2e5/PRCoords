// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "prcoords",
    products: [
        .library(name: "PRCoords", targets: ["PRCoords"]),
        .executable(name: "vecs", targets: ["vecs"]),
    ],
    targets: [
        .target(name: "PRCoords", path: "swift/Sources/PRCoords"),
        .target(name: "vecs", dependencies: ["PRCoords"], path: "swift/Sources/vecs"),
    ],
    swiftLanguageVersions: [.v5]
)
