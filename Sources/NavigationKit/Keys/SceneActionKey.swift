// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

struct SceneActionKey: EnvironmentKey {
    static var defaultValue: SceneAction {
        SceneAction()
    }
}

extension EnvironmentValues {

    /// Sends an action to the views that handle it with ``SwiftUICore/View/sceneAction(for:perform:)``.
    ///
    /// Actions only reach the handlers when a view above both of them called
    /// ``SwiftUICore/View/sceneActionEnabled()``. Without it, the views do not share a scene and the
    /// action is not received by anyone.
    public internal(set) var sceneAction: SceneAction {
        get { self[SceneActionKey.self] }
        set { self[SceneActionKey.self] = newValue }
    }
}

extension View {

    /// Creates the scene that the views below this one use to send actions to each other.
    ///
    /// Call it once, near the root of the hierarchy, so the views that send an action and the ones
    /// that handle it end up in the same scene. The `body` of the `App` is usually the right place:
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .sceneActionEnabled()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Calling it again further down starts another scene. Actions sent below that call do not
    /// reach the handlers above it.
    public func sceneActionEnabled() -> some View {
        environment(\.sceneAction, SceneAction())
    }
}
