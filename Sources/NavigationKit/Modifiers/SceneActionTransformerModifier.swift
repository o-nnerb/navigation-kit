/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

private struct SceneActionTransformerModifier<Action: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction
    let closure: (SceneActionTransformer, Action) -> Void

    func body(content: Content) -> some View {
        content
            .sceneAction(for: Action.self) {
                let transformer = SceneActionTransformer()
                closure(transformer, $0)
                transformer.perform(sceneAction)
            }
    }
}

extension View {

    /**
     Transforms a specific action type to any action type using the transformer. The new action type is used
     to perform an action in the scene.

     - Parameters:
        - actionType: The action type to map from.
        - closure: The closure that accepts a `SceneActionTransformer` instance
     and an item of the specified type. You can use the provided transformer to customize the
     scene action associated with the item.

     - Returns: A modified `View` that performs the scene action using the new action type.
     */
    public func sceneActionTransformer<Action: Hashable>(
        for actionType: Action.Type,
        _ closure: @escaping (SceneActionTransformer, Action) -> Void
    ) -> some View {
        modifier(SceneActionTransformerModifier(closure: closure))
    }
}
