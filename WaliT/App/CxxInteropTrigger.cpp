// Empty translation unit. Xcode only configures a target's Clang importer in
// Objective-C++ mode (needed to `import WalitHashEngine`, a C++ module, alongside
// Foundation/SwiftUI) when the target itself contains a C++ source file directly —
// this target's own sources are otherwise all Swift, so this file exists purely to
// trigger that mode. See project.yml / SWIFT_CXX_INTEROPERABILITY_MODE.
