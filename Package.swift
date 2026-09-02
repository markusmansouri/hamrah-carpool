// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Hamrah",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "HamrahCore", targets: ["HamrahCore"]),
        .library(name: "HamrahData", targets: ["HamrahData"]),
        .library(name: "HamrahDomain", targets: ["HamrahDomain"]),
        .library(name: "HamrahFeatures", targets: ["HamrahFeatures"]),
        .library(name: "HamrahUI", targets: ["HamrahUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/google/googlemap-ios-utils.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        // MARK: - Core Layer
        .target(
            name: "HamrahCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/Core"
        ),
        
        // MARK: - Data Layer
        .target(
            name: "HamrahData",
            dependencies: [
                "HamrahCore",
                "HamrahDomain",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Data"
        ),
        
        // MARK: - Domain Layer
        .target(
            name: "HamrahDomain",
            dependencies: ["HamrahCore"],
            path: "Sources/Domain"
        ),
        
        // MARK: - Features Layer
        .target(
            name: "HamrahFeatures",
            dependencies: [
                "HamrahCore",
                "HamrahData",
                "HamrahDomain",
                "HamrahUI",
            ],
            path: "Sources/Features"
        ),
        
        // MARK: - UI Layer
        .target(
            name: "HamrahUI",
            dependencies: ["HamrahCore"],
            path: "Sources/UI"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "HamrahCoreTests",
            dependencies: ["HamrahCore"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "HamrahDataTests",
            dependencies: ["HamrahData", "HamrahDomain"],
            path: "Tests/DataTests"
        ),
        .testTarget(
            name: "HamrahDomainTests",
            dependencies: ["HamrahDomain"],
            path: "Tests/DomainTests"
        ),
        .testTarget(
            name: "HamrahFeaturesTests",
            dependencies: ["HamrahFeatures"],
            path: "Tests/FeaturesTests"
        ),
    ]
)
