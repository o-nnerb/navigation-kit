// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

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

    /// Sends another action in response to an action of the given type.
    ///
    /// It is the way to translate an action meant for the whole app into the action of the module
    /// that handles it, so the module does not need to know where the action comes from:
    ///
    /// ```swift
    /// .sceneActionTransformer(for: AppAction.self) { transformer, action in
    ///     switch action {
    ///     case .error(let failure):
    ///         transformer(AlertAction.show(failure))
    ///     default:
    ///         break
    ///     }
    /// }
    /// ```
    ///
    /// The original action is not consumed. Its other handlers still receive it, along with the
    /// one sent by the transformer.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action to translate.
    ///    - closure: Receives the action and a ``SceneActionTransformer``. Call the transformer with the
    /// action to send, or do not call it to send nothing.
    ///
    /// - Returns: A view that sends the translated actions.
    public func sceneActionTransformer<Action: Hashable>(
        for actionType: Action.Type,
        _ closure: @escaping (SceneActionTransformer, Action) -> Void
    ) -> some View {
        modifier(SceneActionTransformerModifier(closure: closure))
    }
}
