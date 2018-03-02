// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "KituraWebInterface",
  dependencies: [
    .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.1.0")),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.1")),
    .package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git", .upToNextMinor(from: "2.0.1")),
    .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", .upToNextMinor(from: "1.8.4"))
    ],
  targets: [
    .target(name: "KituraWebInterface", dependencies: ["Kitura" , "HeliumLogger", "CouchDB", "KituraStencil"])
  ]
)
