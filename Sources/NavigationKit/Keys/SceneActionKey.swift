/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

struct SceneActionKey: EnvironmentKey {
    static var defaultValue: SceneAction?
}

extension EnvironmentValues {

    var _sceneAction: SceneAction? {
        get { self[SceneActionKey.self] }
        set { self[SceneActionKey.self] = newValue }
    }

    public var sceneAction: SceneAction {
        guard let _sceneAction else {
            fatalError()
        }

        return _sceneAction
    }
}

extension View {

    public func sceneActionEnabled() -> some View {
        environment(\._sceneAction, .init())
    }
}
