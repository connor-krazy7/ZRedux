// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ZRedux",
    platforms: [.macOS(.v15), .iOS(.v17)],
    targets: [
      .target(
        name: "ZRedux",
        dependencies: ["Differentiable"],
        path: "ZRedux/Sources"
      ),
      .executableTarget(
        name: "ZReduxPlayground",
        dependencies: ["ZRedux"],
        path: "ZReduxPlayground/Sources"
      ),
      
      // MARK: - Differentiable

      .target(
        name: "Differentiable",
        path: "Differentiable/Interface"
      )
    ]
)
