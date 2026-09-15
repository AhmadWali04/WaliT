// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalitHashEngine",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "WalitHashEngine", targets: ["WalitHashEngine"]),
    ],
    targets: [
        // Wraps the existing cpp/ engine (built/tested separately via CMake) as a Swift Package
        // so the iOS app can `import WalitHashEngine` using Swift's native C++ interop.
        .target(
            name: "WalitHashEngine",
            path: "cpp",
            publicHeadersPath: "."
        ),
        .testTarget(
            name: "WalitHashEngineSwiftTests",
            dependencies: ["WalitHashEngine"],
            path: "SwiftTests",
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
