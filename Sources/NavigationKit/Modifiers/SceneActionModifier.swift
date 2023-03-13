/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

private struct SceneActionModifier<Action: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction

    private let action: (Action) -> Void

    init(_ action: @escaping (Action) -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onReceive(
                sceneAction.publisher(for: Action.self),
                perform: action
            )
    }
}

extension View {

    /**
     Adds a scene action to the view.

     Use `sceneAction` to add an action to the view that should trigger when a specific
     type of `Action` is dispatched on the scene.

     - Parameter
        - actionType: The type of the `Action` that should trigger the action.
        - action: A closure that executes when the `actionType` is dispatched.

     - Returns: A modified version of this view that includes the action.
     */
    public func sceneAction<Action: Hashable>(
        for actionType: Action.Type,
        perform action: @escaping (Action) -> Void
    ) -> some View {
        modifier(SceneActionModifier(action))
    }
}
