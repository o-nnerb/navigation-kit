/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

struct SceneActionKey: EnvironmentKey {
    static var defaultValue = SceneAction()
}

extension EnvironmentValues {

    /// The scene action associated with the environment.
    public internal(set) var sceneAction: SceneAction {
        get { self[SceneActionKey.self] }
        set { self[SceneActionKey.self] = newValue }
    }
}
