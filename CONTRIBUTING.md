# Contributor Guide

This project is a standard Swift package.

## Environment setup

The only special thing you might need besides Xcode is [`swiftformat`](https://github.com/nicklockwood/SwiftFormat).
We use it to automatically handle basic formatting and to linting
so the code has a standard style.

Check out the swiftformat [Install Guide](https://github.com/nicklockwood/SwiftFormat?tab=readme-ov-file#how-do-i-install-it)
to add swiftformat to your machine.
Once installed, you can autoformat code using the command:

```sh
swiftformat .
```

Swiftformat can occasionally poorly resolve a formatting issue (e.g. when you've already line-broken a large comment).
Issues like this are typically easy to manually correct. 

## Structure

This package is structured into a few targets. `InternalUtils` is pretty much what it says. `MapLibreSwiftDSL` and
`MapLibreSwiftUI` are published products, and make up the bulk of the project. Finally, `Examples` is a collection of
SwiftUI previews. 

The DSL provides a more Swift-y layer on top of the lower level MapLibre APIs, and features a number of
result builders which enable more modern expressive APIs.

The SwiftUI layer publishes a SwiftUI view with the end goal of being a universal view that can be adapted to a wide
variety of use cases, much like MapKit's SwiftUI views. 

## Testing

You can run the test suite from Xcode using the standard process:
Product menu > Test, or Cmd + U.
If you're having trouble getting a test option / there are no tests,
make sure that the `MapLibreSwiftUI-Package` target is active.

Most of the unit tests are pretty straightforward, but you may notice a few things besides the vanilla testing tools.
We employ snapshot tests liberally to record the state of objects after some operations.
In case you change something which triggers a snapshot change,
you'll get a test failure with some nominally useful info (usually paths to the new and old snapshot).

To record a new snapshot, you can either delete the existing snapshot file on disk
or pass a keyword argument `record: true` to the assertion function.
Then re-run the tests and a new snapshot will be generated (tests will fail one last time with a note that a new snapshot was recorded).

We do not currently have full UI tests.
These are a bit tricky due to the async nature of MapLibre and integrating this into an Xcode UI test is challenging.
If you have any suggestions, we welcome them!

## PRs

If you're using this project and want to improve it, send us a PR!
We have a checklist in our PR template to help reviews go smoothly.

NOTE: If possible, enable maintainer edits when you open PRs.
If your PR is good and just needs a few minor edits to get merged,
we can often put those finishing touches on for you.
In order to allow maintainer edits,
you need to send PRs from a personal fork (org-owned ones have funky auth).
