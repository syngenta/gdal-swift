// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "gdal-swift",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "gdal-swift",
            targets: ["gdal-swift"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "gdal",
            // This URL should be updated after GDAL recompile
            url: "https://github.com/syngenta/gdal-swift/releases/download/gdal-builds/gdal_1.0.1.xcframework.zip",
            // After changing the URL, you should also update the 'checksum'.
            // Run 'swift package compute-checksum gdal.xcframework.zip' command to get the 'checksum'.
            checksum: "0a6ba4992ec20ede9870e8d02cfad2d4ffc0d88d343c24ba82c0fc1b0060bbc3"
        ),
        .target(
            name: "gdal-swift",
            dependencies: ["gdal"],
            path: "Sources",
            exclude: ["gdal"],
            cSettings: [.define("VALID_ARCHS", to: "arm64")],
            cxxSettings: [.define("VALID_ARCHS", to: "arm64")],
            linkerSettings: [
                .linkedLibrary("sqlite3"),
                .linkedLibrary("z"),
                .linkedLibrary("xml2"),
                .linkedLibrary("iconv")
            ]
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: ["gdal-swift"],
            path: "Tests/Tests",
            resources: [.process("Files")],
            cxxSettings: [.define("VALID_ARCHS", to: "arm64")]
        )
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx14
)
