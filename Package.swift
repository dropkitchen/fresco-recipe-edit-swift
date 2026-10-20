// swift-tools-version: 5.10
// fresco-recipe-edit-swift's Package.swift is GENERATED from
// fresco-recipe-edit-ios/dist/Package.swift.template by scripts/render-manifest.sh. Edit the
// template, never the generated file — the next publish overwrites it. The version and the checksum
// must always describe the same artifact, so they are written together or not at all, and every
// dependency range is filled from fresco-recipe-edit-ios's own Package.swift, so the manifest
// cannot disagree with what the artifact was built against.
//
// A deliberately low tools version: a partner on an older Xcode can still resolve this package,
// and nothing here needs a newer manifest API. The iOS floor is the RecipeEdit framework's, not
// this file's.
import PackageDescription

let package = Package(
  name: "fresco-recipe-edit-swift",
  platforms: [.iOS("16.4")],
  products: [
    // The product points at the WRAPPER, not at the binary target. A binaryTarget cannot declare
    // dependencies, so without the wrapper a consumer would link RecipeEdit.framework and neither
    // of the two frameworks it needs at load time.
    .library(name: "RecipeEdit", targets: ["RecipeEditWrapper"])
  ],
  dependencies: [
    // Ranges, not exact pins: `fresco-ios` depends on Pantry directly AND on this package, and
    // SwiftPM fails a graph whose two paths to one identity disagree.
    .package(url: "https://github.com/dropkitchen/fresco-pantry-swift", "0.7.2" ..< "0.8.0"),
    .package(url: "https://github.com/dropkitchen/kitchenos-client-sdk-swift", "2.2.1" ..< "3.0.0")
  ],
  targets: [
    .binaryTarget(
      name: "RecipeEdit",
      url: "https://github.com/dropkitchen/fresco-recipe-edit-swift/releases/download/v1.0.0/RecipeEdit.xcframework.zip",
      checksum: "c05ead462d71b1b451a44dde5248bf60ae7524755a9f37aba1272fc111513669"
    ),
    .target(
      name: "RecipeEditWrapper",
      dependencies: [
        "RecipeEdit",
        .product(name: "Pantry", package: "fresco-pantry-swift"),
        .product(name: "KitchenOS", package: "kitchenos-client-sdk-swift")
      ],
      path: "Sources/Wrapper"
    )
  ]
)
