# Recipe Edit

A complete recipe editing experience, embeddable in your iOS app. Distributed as a pre-compiled
XCFramework.

Part of the **KitchenOS Flows SDK**. A *Flow* is a whole user journey rather than a component
library: you present it, your user completes it, and you get told what happened.

> **This is a `0.x` release and it is a skeleton.** The public contract below is final and safe to
> build against, but there is no editor behind it yet: `authenticate` grants a session without
> contacting KitchenOS, and `show` presents a placeholder. `RecipeEditorInfo.isStub` reports `true`
> for every `0.x` build and `false` from `1.0.0`. Integrate against it now if you want the
> integration done early; do not ship it to users.

## Install

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/dropkitchen/fresco-recipe-edit-swift", from: "0.1.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "RecipeEdit", package: "fresco-recipe-edit-swift")
    ])
]
```

In Xcode: **File → Add Package Dependencies…** and paste
`https://github.com/dropkitchen/fresco-recipe-edit-swift`.

No credentials are required. The manifest resolves over anonymous HTTPS and every artifact
downloads from a public release asset.

**One dependency is all you add.** Recipe Edit brings the design system and the KitchenOS client
SDK with it; you never declare either.

Add the package to your **app target only**. Adding an XCFramework to an app extension as well puts
it in both `Frameworks/` and `PlugIns/`, and App Store validation rejects it with
`The bundle contains disallowed nested bundles` — at submission, not at build.

## Use

Six calls. Everything else is a value type you pass in or receive back.

```swift
import RecipeEdit

// At app start
RecipeEditor.initialise(
    RecipeEditConfiguration(
        kitchenOS: KitchenOSConfiguration(
            clientID: "your-client-id",
            environment: .stage,
            region: "us-east-2"
        ),
        theme: RecipeEditTheme(
            brandColors: RecipeEditBrandColors(primary: brandColour, action: brandColour)
        )
    )
)

// A provider, not a token — see below
RecipeEditor.authenticate(.hostIdentity { await session.currentAccessToken() })

// Where your user taps Edit
RecipeEditor.show(
    from: viewController,
    request: RecipeEditRequest(recipeID: recipe.id, measurementUnits: .metric)
)

// Where you keep your recipe list
Task {
    for await event in RecipeEditor.editEvents {
        if case .recipeSaved = event { await refreshRecipeList() }
    }
}
```

`RecipeEditor.signOut()` is the sixth, and `RecipeEditor.authStatus` the remaining one — a stream
with a `current` value you can read at any time, including before `initialise`.

`RecipeEditorInfo.version` reports which build you linked. It is the first thing to include in a
defect report.

### Four things that surprise people

**The type is `RecipeEditor`, the module is `RecipeEdit`.** A public Swift type cannot share its
module's name under library evolution, so the entry point takes the longer one. If you are porting
from our Android SDK, this is the only call-site difference between the two.

**`measurementUnits` has no default.** You know what units your user reads in everywhere else in
your app; we do not, and a default would be our opinion applied silently to your screen.

**`hostIdentity` takes a provider, not a token.** An exchanged KitchenOS session cannot be
refreshed, so on expiry we ask you for a fresh one. Return `nil` — never a stale token — once your
own user has signed out; that is reported back as `.hostSessionEnded`, which correctly says the fix
is yours.

**Both streams are multicast.** Observe `authStatus` and `editEvents` from as many places as you
like. Every observer sees everything.

## Theming

Three brand colours and a font family. Everything else — the type scale, spacing, semantic colours,
component structure, iconography and every string — is fixed, because those are what keep the
screens correct and translatable.

We render your colours exactly as supplied and make no accessibility claim about the result.
Contrast is yours to choose.

## What you get

Three dynamic frameworks, embedded in your app automatically:

| | Download | Why it is there |
|---|---|---|
| `RecipeEdit.xcframework` | 28 MB | The flow |
| `Pantry.xcframework` | 37 MB | The design system it renders with |
| `KitchenOS.xcframework` | 23 MB | The client SDK it talks to the platform through |

Download size is not app size: the device slice of Recipe Edit's binary is about **3 MB**, and the
rest is the simulator slice and the dSYMs. Each artifact is resolved once and cached by checksum.

- `ios-arm64` and `ios-arm64_x86_64-simulator`, with dSYMs so your crash reports symbolicate.
- iOS 16.4 and later. No Mac Catalyst or visionOS slice.
- **No analytics, crash-reporting or advertising SDK**, and no permissions beyond network access.
- A privacy manifest declaring no tracking and no data collection.
- No third-party module in the public API, so your own dependency versions are unaffected by ours.
  We compile ours in and do not export them — use whatever versions you like.

Third-party components compiled into the artifact are listed in
[THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md). Terms are in [LICENSE](LICENSE).

## Versions

Semantic versioning. Tags are `vX.Y.Z`. Anything below `1.0.0` is pre-release and its API may change
without a major bump.

Each release records its artifact size, SHA-256 checksum, build toolchain and the versions it was
built against in [CHANGELOG.md](CHANGELOG.md).

**A published tag is never deleted or re-pointed.** SwiftPM caches resolved artifacts by checksum,
so replacing the bytes behind a tag would break every consumer already pinned to it. A bad release
is superseded by a new patch version and marked as superseded in the changelog.

## Troubleshooting

**`multiple packages … declare targets with a conflicting name: 'KitchenOS'`**

You have two routes to the KitchenOS SDK in one dependency graph. The usual cause is depending on
an older coordinate for it directly while also depending on this package.

Depend on `https://github.com/dropkitchen/kitchenos-client-sdk-swift` and nothing else, or drop your
direct dependency entirely and let it arrive through this package. SwiftPM derives package identity
from the URL, so a `git@` form, a trailing `.git`, or a different repository name all count as a
*second, different* package even when the contents are identical. This is not a defect in the SDK.

**`no such module 'Pantry'`** — you are depending on the binary target rather than the package
product. Use `.product(name: "RecipeEdit", package: "fresco-recipe-edit-swift")`, exactly as in the
Install snippet; that is what pulls in the frameworks Recipe Edit needs at launch.

**Source is not available.** This repository holds a manifest and release assets. That is
deliberate — the artifact is pre-compiled so that our internal dependency versions can never
conflict with yours.
