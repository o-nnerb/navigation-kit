# Supporting Earlier OS Versions

What changes on iOS 15, tvOS 15 and macOS 12.

## Overview

`NavigationStack` and `NavigationPath` arrived in iOS 16, tvOS 16 and macOS 13. NavigationKit supports
the versions before them, and ``NKNavigationStack`` and ``NKNavigationSplitView`` use an equivalent
implementation there. The code that uses the library is the same on every version, and the system
navigation is still the one used where it exists. watchOS 9 and visionOS 1 already have it.

Test on the earliest version you ship, because the behavior of the transitions differs.

### What is different

- **iOS and tvOS** show a `NavigationView`. The system ignores a push that starts while another is in
  progress, so the items are shown one at a time, each after the previous push finishes. Calling
  `setItems(_:)` with several items takes that many transitions to show them all.
- **macOS 12** has no push navigation in `NavigationView`. The items are stacked on top of the
  content, with a back button in the toolbar.
- SwiftUI's `navigationDestination(for:destination:)` does not exist there. Use
  ``SwiftUICore/View/nkNavigationDestination(for:destination:)``, which works on every version.
- The ``NKNavigationSplitView`` initializers that take `columnVisibility` need iOS 16, tvOS 16 or
  macOS 13. The other ones work on every version.
- The ``NavigationAction/codable`` representation is the same on every version, so a stack saved on
  one version can be restored on another.

### What stays the same

``NavigationAction``, ``SceneAction``, ``ViewResolver`` and ``ObjectConnection`` behave the same.
The Observation framework is the exception: it needs iOS 17, tvOS 17, macOS 14, watchOS 10 or
visionOS 1, so a view model that must run before that remains an `ObservableObject`. See
<doc:Coordinators>.
