# ``NavigationKit``

Move between SwiftUI screens, and send actions across a view hierarchy, without the views knowing about each other.

## Overview

In plain SwiftUI a view that pushes another screen has to know which screen that is, and usually
how it is built. That coupling gets in the way as soon as the app is split in modules or when the
same screen is reached from more than one place.

NavigationKit puts the stack, the lookup of views and the communication between screens in the
environment. A view asks for what it needs and the code that sets up the hierarchy decides the rest:

- ``NKNavigationStack`` and ``NKNavigationSplitView`` own the stack. The views push and pop through
  ``NavigationAction`` instead of a `NavigationPath` binding.
- ``ViewResolver`` builds the view for a model, so a screen can show another one given only its model.
- ``SceneAction`` sends an action to whoever handles it, wherever that is in the hierarchy.
- ``ObjectConnection`` creates the view model of a screen, which is what a coordinator needs to
  react to the model and navigate.

It runs on iOS 15, tvOS 15, macOS 12, watchOS 9 and visionOS 1. On the versions without
`NavigationStack` an equivalent implementation is used, with the same API.

## Topics

### Essentials

- <doc:GettingStarted>

### Navigating

- <doc:NavigationStacks>
- ``NKNavigationStack``
- ``NKNavigationSplitView``
- ``NavigationAction``
- ``NavigationAction/CodableRepresentation``
- ``SwiftUICore/EnvironmentValues/navigationAction``
- ``SwiftUICore/View/nkNavigationDestination(for:destination:)``

### Showing a screen by its model

- <doc:ViewResolvers>
- ``ViewResolver``
- ``SwiftUICore/EnvironmentValues/viewResolver``
- ``SwiftUICore/View/viewResolver(for:_:)``

### Sending actions between screens

- <doc:SceneActions>
- ``SceneAction``
- ``SwiftUICore/EnvironmentValues/sceneAction``
- ``SwiftUICore/View/sceneActionEnabled()``
- ``SwiftUICore/View/sceneAction(for:perform:)``
- ``SwiftUICore/View/sceneActionSheet(for:reducer:)``
- ``SwiftUICore/View/sceneActionSheet(for:)``
- ``SwiftUICore/View/sceneActionPopover(for:attachmentAnchor:arrowEdge:reducer:)``
- ``SwiftUICore/View/sceneActionPopover(for:attachmentAnchor:arrowEdge:)``

### Translating actions and items

- ``SceneActionTransformer``
- ``SwiftUICore/View/sceneActionTransformer(for:_:)``
- ``NavigationDestinationTransformer``
- ``SwiftUICore/View/navigationDestinationTransformer(for:closure:)``

### Building a screen

- <doc:Coordinators>
- ``ObjectConnection``
- ``SceneTransaction``
- ``ViewState``
- ``SwiftUICore/View/viewState(_:)``
- ``SwiftUICore/View/viewState(_:keyPath:)``

### Organizing an app

- <doc:ModularApps>
- <doc:SupportingEarlierOSVersions>

### Other types

- ``Closure``
