This project has migrated from Stadia Maps to the MapLibre organization!

Xcode and GitHub normally handle these sorts of changes well,
but sometimes they don't.
So, you'll probably want to be proactive and change your URLs from
`https://github.com/stadiamaps/maplibre-swiftui-dsl-playground`
to `https://github.com/maplibre/swiftui-dsl`.

If you're building a plain Xcode project, it might actually be easier to remove the Swift Package
and all of its targets and then re-add with the URL.

Swift Package authors can simply update the URLs.
Note that the package name also changes with the repo name.

```swift
    .product(name: "MapLibreSwiftDSL", package: "swiftui-dsl"),
    .product(name: "MapLibreSwiftUI", package: "swiftui-dsl"),
```
