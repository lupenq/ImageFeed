# AGENTS.md

## Project Overview

**ImageFeed** is a native iOS (Swift/UIKit) application that serves as an image browsing client for the Unsplash API. It features OAuth 2.0 authentication, an image feed, single-image zoom view, and a user profile screen.

- **Language:** Swift 5.0
- **Frameworks:** UIKit, WebKit
- **Target:** iOS 17+, iPhone only (portrait)
- **Project type:** Xcode project (`ImageFeed.xcodeproj`), no SPM/CocoaPods/Carthage dependencies
- **No third-party dependencies** — uses only Apple system frameworks

## Cursor Cloud specific instructions

### Platform limitation

This is a **native iOS Xcode project**. It **cannot be fully built or run** on a Linux Cloud Agent VM — it requires macOS with Xcode and an iOS Simulator or physical device. The Cloud Agent environment provides **syntax checking and linting only**.

### Available tools on Linux

- **Swift 6.1.2** is installed at `/opt/swift/usr/bin/swift` (added to `PATH` via `~/.bashrc`). Use `swiftc -parse <file.swift>` to syntax-check individual Swift files without requiring UIKit/WebKit frameworks.
- **SwiftLint 0.63.2** is installed at `/usr/local/bin/swiftlint`. Run from project root to lint all Swift files.

### Lint

```bash
cd /workspace && swiftlint lint
```

The codebase currently has pre-existing SwiftLint violations (29 violations, 5 errors). These are in the original code. When making changes, ensure no new violations are introduced.

### Syntax check

```bash
export PATH="/opt/swift/usr/bin:$PATH"
swiftc -parse ImageFeed/SomeFile.swift
```

Note: `swiftc -parse` only checks syntax — it does not resolve imports like `UIKit` or `WebKit`, so import-related errors are expected and can be ignored. Pure Swift syntax errors are real.

### Build & Run (macOS only)

Full build and run requires macOS with Xcode 16+:

```bash
xcodebuild -project ImageFeed.xcodeproj -scheme ImageFeed -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Key files

- `ImageFeed/Constants.swift` — Unsplash API credentials and base URL
- `ImageFeed/Auth/` — OAuth 2.0 authentication flow
- `ImageFeed/ImagesList/` — Image feed table view
- `ImageFeed/SplashViewController.swift` — Entry point after launch, handles auth routing
