# WDLive Copilot Instructions

## Project Overview

WDLive is an iOS live-streaming app built with Swift and UIKit. It features a 4-tab layout (Home, Discover, Chat, Profile), a live room screen with gift animations, and a network layer backed by the Netease Cloud Music API.

## Build & Lint

- Open `WDLive.xcworkspace` in Xcode (not `.xcodeproj`) after running `pod install`
- Dependencies managed via CocoaPods: `pod install` / `pod update`
- Lint: SwiftLint 0.46.3 is integrated as a CocoaPods pod and runs during Xcode build
  - Config in `.swiftlint.yml` — scoped to `WDLive/`, excludes `Pods/` and `Carthage/`
  - Line length: warning at 150, error at 250
  - Disabled rules: `identifier_name`, `force_cast`
  - Opt-in rules: `empty_count`, `explicit_init`
  - Use `// swiftlint:disable <rule>` at file top or inline for intentional suppressions

## Architecture

### Navigation & Tabs
- `AppDelegate` sets a global `UINavigationBarAppearance` (dark gray, non-translucent)
- `WDTabBarController` loads each tab from its own Storyboard by name: `Home`, `Discover`, `Chat`, `Profile`
- `BaseNavigationController` automatically sets `hidesBottomBarWhenPushed = true` on every pushed VC and forces `UIStatusBarStyle.lightContent`

### Network Layer
Three-file design in `WDLive/Network/`:
1. `WDRequestMethod` — enum for HTTP verbs
2. `WDRequestable` — protocol defining a request: `path`, `method`, `headers`, `parameters`, and an associated `Response: Decodable`. Default method is `.GET`
3. `WDRequestClient` — concrete `Client` that uses Alamofire + SwiftyJSON. Checks `json["code"] == 200`, decodes `json["result"]` into the `Response` type

To add a new API call, define a struct conforming to `WDRequestable` (see `RoomRequest.swift` → `MusicRequest` as the canonical example), then call `WDRequestClient().send(request) { result in ... }`.

The base host is `https://neteasecloudmusicapi.vercel.app`.

### Custom Reusable Components (WDLive/Base/)

| Component | Purpose |
|---|---|
| `WDPagerView` | Horizontally scrollable tab pager. Compose with `WDPagerStyle` struct for configuration, pass `titles`, child VCs, and parent VC. Title view and content view are two-way delegates of each other. |
| `WDWaterfallCollectionLayout` | Pinterest-style waterfall `UICollectionViewFlowLayout`. Requires conformance to `WDWaterfallCollectionLayoutDataSource` to supply per-item height. Supports incremental loading (only recalculates from new items). |
| `NibLoadEnable` | Protocol with default `loadNibView() -> Self` that loads a XIB named after the class. Adopt in any `UIView` subclass that has a matching `.xib`. |
| `UIColor` extensions | `UIColor(r, g, b)`, `UIColor(hex:)`, `UIColor.randomColor`, `UIColor.getDeltaColor(_:_:)` |
| `UIView` `@IBInspectable` extensions | `cornerRadius`, `borderWidth`, `borderColor` — editable in Interface Builder |

### Room & Gift Hit Panel (WDLive/Room/)
The gift panel (`GiftHitsPanel/`) uses a small pool of `GiftHitsCellView` cells managed by `GiftHitsContainerView`:
- `GiftHitsContainerView.show(_ gift:)` — public entry point; checks for in-flight duplicates, uses an idle cell, or queues to `giftCacheQueue`
- Cells animate through states: `idle → displayAnimating → willDismiss → dismissAnimating → idle`
- `GiftDigitLabel` draws text with a stroke+fill technique using `CoreGraphics` for outlined numbers
- `EmitterEnableProtocol` provides default `startEmitter()` / `stopEmitter()` via a `CAEmitterLayer`; conform any `UIViewController` to get particle effects for free

## Key Conventions

- **One Storyboard per feature module**: `Home.storyboard`, `Room.storyboard`, `Chat.storyboard`, `Discover.storyboard`, `Profile.storyboard`. Each is the initial VC of its navigation stack.
- **Extensions by concern**: VCs are split into `// UI`, `// 事件` (event handlers), and protocol conformance extensions in separate `extension` blocks within the same file.
- **IBAction / IBOutlet pattern**: Room screen wires actions directly via Storyboard; gift panel uses delegate callbacks.
- **`GiftModel` equality**: Two gifts are equal if `id` and `username` match — used to coalesce hit animations.
- **Suppress long-line lint warnings** with `// swiftlint:disable line_length` when UIKit setup code exceeds 150 chars (see `AppDelegate.swift`, `WDWaterfallCollectionLayout.swift`).
