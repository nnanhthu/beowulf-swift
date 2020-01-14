// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Beowulf",
    products: [
        .library(name: "Beowulf", targets: ["Beowulf"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable.git", .revision("396ccc3dba5bdee04c1e742e7fab40582861401e")),
        .package(url: "https://github.com/jnordberg/OrderedDictionary.git", .branch("swiftpm")),
    ],
    targets: [
        .target(
            name: "Crypto",
            dependencies: []
        ),
        .target(
            name: "secp256k1",
            dependencies: []
        ),
        .target(
            name: "Beowulf",
            dependencies: ["Crypto", "AnyCodable", "OrderedDictionary", "secp256k1"]
        ),
        .testTarget(
            name: "BeowulfTests",
            dependencies: ["Beowulf"]
        ),
        .testTarget(
            name: "BeowulfIntegrationTests",
            dependencies: ["Beowulf"]
        ),
    ]
)
