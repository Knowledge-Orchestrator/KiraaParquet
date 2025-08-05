// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "KiraaParquet",

    platforms: [
        .macOS(.v14)
    ],

    // ────────────────────────────────────────────
    // Products
    // ────────────────────────────────────────────
    products: [
        /// Core SDK that other apps import.
        .library(
            name: "KiraaParquet",
            targets: ["KiraaParquet"]
        ),

        /// Handy CLI / Xcode “Run” binary.
        .executable(
            name: "KiraaParquetExecutor",
            targets: ["KiraaParquetExecutor"]
        )
    ],

    // ────────────────────────────────────────────
    // Targets
    // ────────────────────────────────────────────
    targets: [

        //---------------------------------------------------------------
        // 1. C++ bridge wrapping libarrow / libparquet
        .target(
            name: "ParquetBridge",
            path: "Sources/ParquetBridge",
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags(["-std=c++17", "-I/opt/homebrew/include"])
            ],
            linkerSettings: [
                .unsafeFlags(["-L/opt/homebrew/lib"]),
                .linkedLibrary("arrow"),
                .linkedLibrary("parquet"),
                .linkedLibrary("thrift"),
                .linkedLibrary("z")
            ]
        ),

        //---------------------------------------------------------------
        // 2. Pure-Swift façade
        //---------------------------------------------------------------
        .target(
            name: "KiraaParquet",
            dependencies: ["ParquetBridge"],
            path: "Sources/KiraaParquet"
        ),

        //---------------------------------------------------------------
        // 3. Command-line tool (optional for SDK consumers)
        //---------------------------------------------------------------
        .executableTarget(
            name: "KiraaParquetExecutor",
            dependencies: ["KiraaParquet"],
            path: "Sources/KiraaParquetExecutor"
        ),

        //---------------------------------------------------------------
        // 4. Unit tests
        //---------------------------------------------------------------
        .testTarget(
            name: "KiraaParquetTests",
            dependencies: ["KiraaParquet"],
            path: "Tests/KiraaParquetTests"
        )
    ]
)
