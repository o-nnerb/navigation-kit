// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

struct SceneActionKey: EnvironmentKey {
    static var defaultValue: SceneAction {
        SceneAction()
    }
}

extension EnvironmentValues {

    /// The scene action associated with the environment.
    public internal(set) var sceneAction: SceneAction {
        get { self[SceneActionKey.self] }
        set { self[SceneActionKey.self] = newValue }
    }
}

extension View {

    public func sceneActionEnabled() -> some View {
        environment(\.sceneAction, SceneAction())
    }
}
