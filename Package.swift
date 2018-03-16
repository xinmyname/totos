// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "totos",
    dependencies: [
        .package(url: "https://github.com/jernejstrasner/CCommonCrypto.git", .branch("master"))
    ],
    targets: [
        .target(
            name:"totos"
        )
    ]
)
