/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

private struct SceneActionMapper<Action: Hashable, NewAction: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction
    private let mapper: (Action) -> NewAction

    init(mapper: @escaping (Action) -> NewAction) {
        self.mapper = mapper
    }

    func body(content: Content) -> some View {
        content
            .sceneAction(for: Action.self) {
                sceneAction(mapper($0))
            }
    }
}

extension View {

    /**
     Maps a specific action type to a new action type using a mapper function. The new action type is used
     to perform an action in the scene.

     - Parameters:
        - actionType: The action type to map from.
        - mapper: A function that takes an action of type `Action` and maps it to a new action of type `NewAction`.

     - Returns: A modified `View` that performs the scene action using the new action type.
     */
    public func sceneActionMap<Action: Hashable, NewAction: Hashable>(
        for actionType: Action.Type,
        _ mapper: @escaping (Action) -> NewAction
    ) -> some View {
        modifier(SceneActionMapper(mapper: mapper))
    }
}
