// Intentionally empty.
//
// This target exists only to carry dependencies. A `binaryTarget` cannot declare any, so the
// package's `RecipeEdit` product points at this target instead, and SwiftPM then links and embeds
// Pantry.framework and KitchenOS.framework into any app that depends on this package — without
// the app ever naming either of them.
//
// That is the whole mechanism behind D5 ("no umbrella package in V1"): a partner writes one
// dependency and one import, and receives three frameworks. It is the pattern Firebase uses
// (`FirebaseAnalyticsWrapper`).
//
// The file has to exist even though it declares nothing: SwiftPM refuses a target whose source
// directory is empty, with "Source files for target RecipeEditWrapper should be located under
// Sources/Wrapper".
//
// Two things not to add here:
//
//   1. Code. This is the only source file in a repository whose entire purpose is to hold no
//      source (structure spec §3, invariant 5 — amended for exactly this file, and no further).
//
//   2. `@_exported import RecipeEdit`. The binary target is already a dependency of this target,
//      so `import RecipeEdit` resolves to the framework's module in a consumer. An @_exported
//      import would make `RecipeEditWrapper` a second usable name for the same module and put it
//      in partners' completion lists, which is the opposite of a small public surface.
