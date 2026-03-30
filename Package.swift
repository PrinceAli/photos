// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "photos",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "PhotosCore",
            linkerSettings: [
                .linkedFramework("Photos"),
            ]
        ),
        .executableTarget(
            name: "ExportPhotos",
            dependencies: [
                "PhotosCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/ExportPhotos/Info.plist",
                ]),
            ]
        ),
    ]
)
