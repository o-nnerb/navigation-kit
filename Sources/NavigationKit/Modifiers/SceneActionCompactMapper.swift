/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

private struct SceneActionCompactMapper<Action: Hashable, NewAction: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction
    private let mapper: (Action) -> NewAction?

    init(mapper: @escaping (Action) -> NewAction?) {
        self.mapper = mapper
    }

    func body(content: Content) -> some View {
        content
            .sceneAction(for: Action.self) {
                if let newAction = mapper($0) {
                    sceneAction(newAction)
                }
            }
    }
}

extension View {

    /**
     Maps a scene action to a new action using a closure that returns an optional value.

     - Parameters:
        - actionType: The type of the original scene action.
        - mapper: A closure that maps an original scene action to a new action.
     - Returns: A view that maps an original scene action to a new action using the provided closure.
     */
    public func sceneActionCompactMap<Action: Hashable, NewAction: Hashable>(
        for actionType: Action.Type,
        _ mapper: @escaping (Action) -> NewAction?
    ) -> some View {
        modifier(SceneActionCompactMapper(mapper: mapper))
    }
}
