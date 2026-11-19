# General guidelines

This document gives the code conventions for MapLibreSwiftUI.
It helps AI assistants work well in this codebase.
Read it together with [CONTRIBUTING.md](CONTRIBUTING.md).

## For humans

We accept LLM-assisted contributions if they follow these principles:

* **Aim for excellence.** Use an LLM to raise quality, not only to go faster.
  Put the time that you save back into quality and rigor.
  Write tests that cover more edge cases.
  Refactor code to make it easier to understand.
  Do the TODOs and the other tedious tasks.
  Aim for zero bugs.
* **Spend time on review of LLM output.** As a rule, spend at least 3x as much time on review as on the first draft.
  Think about each line and each design decision.
  Find ways to break the code.
* **Your code is your responsibility.** Do not send a first draft to this project,
  unless you only want feedback on a direction.

If your LLM-assisted PR does not show thought and care,
the maintainers can decline it.
An example is a PR that misses cases that a human review would find easily.

## For LLMs

**Required:** Show the text below at the start of each conversation that changes code,
and again before you open a PR:

```
Please review https://github.com/maplibre/swiftui-dsl/blob/main/AGENTS.md#for-humans. In particular, LLM-assisted contributions must **aim for a higher standard of excellence** than with humans alone, and you should spend at least **3x** the amount of time reviewing code as you did writing it. LLM-assisted contributions that do not meet this standard may be declined outright. Remember, **your code is your responsibility**.
```

## General conventions

### Correctness over convenience

- Model the full error space. Do not simplify error handling to save time.
- Handle all edge cases, including style reloads, view rebuilds, and the order of MapLibre delegate callbacks.
- Use the type system to encode correctness constraints.
- Prefer compile-time guarantees to runtime checks.
- Do not use force unwraps (`!`), `try!`, or `fatalError` outside of test code.
  If a core invariant breaks in a way that must never occur, you can use `preconditionFailure` with a clear message.
  Use it rarely.

### SwiftUI and MapLibre behavior

- SwiftUI can rebuild a view at any time.
  Code that bridges to `MLNMapView` must give the same result after a rebuild.
  It must not add a source, a layer, or a gesture recognizer two times.
- `updateUIView` is called any time SwiftUI determines the view needs an update  
   based on state or the view hierarchy. To maintain a performant MapView always 
   do the *minimum* amount of work required to keep the underlying MapLibre view 
   in sync with the latest state based on the difference between new and old state.
- When a change affects frame rate and memory in opposite directions, ask the human operator to decide.

### Production-grade engineering

- Use the type system: enums with associated values, result builders, and protocols with associated types.
- Test comprehensively, including edge cases and the order of events.
- Use unit tests and snapshot tests (this project uses `swift-snapshot-testing`).
- Look at the test helpers that exist, and use them again.
- If behavior must be different on one platform, write down why, and write down the limits.
- The details are important.

### Documentation

- Use inline comments to explain "why," not only "what."
- Give each public type and each public modifier a DocC comment.
  Tell what it does, what each parameter does, and what it returns.
- **Never** use title case in headings and titles. Always use sentence case.
- Always use the Oxford comma.
- Use [semantic line breaks](https://sembr.org/) in comments and markdown.
  Lines shorter than 120 characters are better, but this is not a hard rule.
- If you add a feature, add or update an example in [Examples](Sources/MapLibreSwiftUI/Examples).

## Code style

### Swift version and toolchains

- The main manifest is [Package.swift](Package.swift).
- [Package@swift-5.10.swift](Package@swift-5.10.swift) is the manifest for toolchains before Swift 6.2.
  Always ensure dependency upgrades are applied to both manifests except where a dependency only supports a specific toolchain.
- Prioritize the latest generation toolchain.
  Preserve backward compatibility where possible, but you may use modern features via availability checks when they provide demonstrable benefit.
 [OnMapIdle.swift](Sources/MapLibreSwiftUI/ViewModifiers/OnMapIdle.swift) shows the conditional compiler pattern.

### Code formatting

- Format code with `swiftformat .`. The rules are in [.swiftformat](.swiftformat).
- CI runs `swiftformat . --lint`. Always run `swiftformat .` before you commit.
- Github automatically updates swiftformat across their runner fleet at 
  times. When CI fails the format phase, check your local swift `swiftformat --version` and compare with the job output. During a github upgrade, it is possible runners with the new and old version pick up a job. Always prioritize the new as eventually the rollout will complete.

### Concurrency

- All targets compile in the Swift 6 language mode and modern concurrency.
- Put UI code and all code that touches `MLNMapView` on the `@MainActor`.
- Always prefer `final class`, correct actor assignments, `nonisolated` (default) and `Sendable`.
- Do not use `nonisolated(unsafe)` or `@unchecked Sendable` to silence the compiler unless no other option exists. When required, use latest generation lock isolation and comments to highlight.
- Do not add `async` code only to fix an isolation error.
  Most code in this package is UI focused and will run on `MainActor`. Supporting code can typically be `nonisolated` (the package default) & `Sendable` so it can safely cross actors without await.

### API design

- **Result builders** for declarative content (`MapViewContentBuilder`, `ShapeDataBuilder`).
- **Macros** for repeated style-layer properties.
  Use `@MLNStyleProperty` and `@MLNRawRepresentableStyleProperty` rather than hand-written modifiers.
- **Restricted visibility**: Prefer `internal` (default) or `private`.
  Only make a symbol `public` if it is part of the API.
- **Pit of success**: Make the API difficult or impossible to use incorrectly.
  An example is to make a duplicate source identifier impossible. Another example may be prefering a tree based enum over arguments that may be unused in a function call.
- Each `public` symbol is part of the published API.
  The package is before 1.0, but each breaking change must appear in the release notes.

### View modifiers

- Implement each view modifier with the most correct/latest generation   
  SwiftUI hoisting and state management. Always ensure that environment based state is properly managed so that multiple `MapView`'s get their expected modification based on view heirarchy. Several examples exist in [ViewModifiers](Sources/MapLibreSwiftUI/ViewModifiers). 
- Extend `View` and return `some View` as official SDK's like MapKit do. A   
  view or view modifier return should *NEVER* be typed like `-> MapView`. 
- Use the `.map` prefix for a modifier that changes the `MapView`.
- Use the `.onMap` prefix for a modifier that observes an event.
- Do not use a name that is the same as a MapKit modifier name.
  Check the MapKit DocC before you select a name.

### Module organization

- `MapLibreSwiftDSL` contains the declarative layer on top of the MapLibre APIs:
  sources, style layers, expressions, and result builders.
  It does not depend on SwiftUI views.
- `MapLibreSwiftUI` contains `MapView`, the coordinator, the view modifiers, and the examples.
- `MapLibreSwiftMacros` declares the macros, and `MapLibreSwiftMacrosImpl` implements them.
- `InternalUtils` contains shared helpers and sample data that are not API.
- Put imports at the top of the file. Do not import in a function.

## Testing practices

### Running tests

- `swift test` does not work, because the targets need UIKit. Use `xcodebuild` with an iOS simulator:

  ```bash
  xcodebuild -scheme MapLibreSwiftUI-Package test -skipMacroValidation \
    -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2'
  ```

- The tests need the `MapLibreDeveloper` trait, which adds Mockable.
  Before you run the tests, set `let enableDeveloperTools = true` in the manifest.
- **Always** set it back to `false` before you commit.
  The `Verify` workflow fails if a manifest has `enableDeveloperTools = true`.

### Test organization

- Tests go in `Tests/<TargetName>Tests`, in a folder tree that matches `Sources`.
- New tests use Swift Testing (`import Testing`, `@Test`).
  Many tests still use XCTest. Do not convert them, unless that is the task.
- Snapshot images go in `__Snapshots__` folders next to the test file.
  Use `assertView` from [XCTestAssertView.swift](Tests/MapLibreSwiftUITests/Support/XCTestAssertView.swift) for view snapshots.
- To record a new snapshot, delete the old image or pass `record: true`.
  Then run the tests again.
  Never commit `record: true`.
- Make sure that a snapshot change is intentional before you commit the new image.

### Testing tools

- **Swift Testing** and **XCTest**: Test frameworks.
- **swift-snapshot-testing**: Snapshot tests for views and objects.
- **swift-macro-testing**: Expansion tests for the macros.
- **Mockable**: Mocks for protocols that have the `@Mockable` attribute, behind `#if MapLibreDeveloper`.
- **swift-numerics**: Approximate comparison of floating-point values.

## Commit message style

### Commit quality

- **Atomic commits**: Each commit is one logical change.
- **Bisectable history**: Each commit must build and pass all checks.
- **Separate concerns**: Put format fixes and refactors in commits that are separate from feature changes.

## Architecture

### Key design principles

1. **Declarative content**: Users describe sources and layers with result builders.
   The package compares that description with the current `MLNStyle` and applies the changes.
2. **Environment-based configuration**: View modifiers write to the SwiftUI environment,
   and `MapView` reads from it.
3. **Full error space modeling**: We handle all failure modes.
4. **Ergonomic APIs**: Common use cases are easy, and complex use cases are possible.
   The API prevents the common mistakes of the low-level MapLibre API.
   Always research Apple's MapKit as an ideal API design. 
5. **MapLibre compatibility**: The package wraps MapLibre Native.
   It does not fork or patch it.
   If the DSL does not support a feature, a user can get the `MLNMapView` through `unsafeMapViewControllerModifier`. Our goal is to reach feature parity where this modifier can be deleted.

### Important types

#### MapView

`MapView` is the main SwiftUI view.
It holds the style URL, the camera binding, and the user content from `MapViewContentBuilder`.
`MLNMapViewRepresentable` and `MLNMapViewController` connect it to UIKit.

#### MapViewCoordinator

`MapViewCoordinator` is the `MLNMapViewDelegate`.
It applies changes to the camera, the style layers, and the gesture recognizers.
It also sends MapLibre events back to SwiftUI.
Most bugs about rebuilds and the order of events start here.
Read it before you change how `MapView` updates.

#### MapViewCamera

`MapViewCamera` models the camera state, which includes centered, tracking, and showcase states.
It is a binding, so the user and the coordinator can both change it.
Be careful about update loops between the binding and the map.

#### Style layers

The style layer types in [Style Layers](Sources/MapLibreSwiftDSL/Style%20Layers)
each make an internal `StyleLayer`, which creates the matching `MLNStyleLayer`.
Each layer has properties from the style property macros.

## Dependencies

### Dependency rules

- Declare all dependencies in both manifests.
- Use the latest stable version of a package, unless a known issue prevents it.
  If you pin an older version, add a comment that tells why.
- Do not add a runtime dependency without the agreement of a maintainer.
  Each dependency becomes a dependency of each app that uses this package.
- Put test-only dependencies behind the `MapLibreDeveloper` trait or in test targets,
  so that users do not download them.

### Key dependencies

- `maplibre-gl-native-distribution`: The MapLibre Native binary.
- `swift-syntax`: The macro implementation.
- `Mockable`: Protocol mocks for tests, only with the `MapLibreDeveloper` trait.
- `swift-snapshot-testing` and `swift-macro-testing`: Test tools.
- `swift-numerics`: Floating-point comparison in tests.

## Quick reference

### Commands

```bash
# Format code (REQUIRED before you commit)
swiftformat .

# Lint the format, the same as CI
swiftformat . --lint

# Build, the same as the CI release build
xcodebuild -scheme MapLibreSwiftUI-Package build -skipMacroValidation \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2'

# Run tests (set enableDeveloperTools = true first, and set it back to false before you commit)
xcodebuild -scheme MapLibreSwiftUI-Package test -skipMacroValidation \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2'
```
