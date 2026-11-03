// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftAsyncStream
import SwiftUI

/// Sends an action, any `Hashable` value, to the views of a scene that handle its type.
///
/// Get one from the `sceneAction` environment value and call it with the action. Whoever sends
/// does not know who handles it, and the handlers are registered with
/// ``SwiftUICore/View/sceneAction(for:perform:)``:
///
/// ```swift
/// enum SessionAction: Hashable {
///     case logout
/// }
///
/// struct SettingsView: View {
///     @Environment(\.sceneAction) private var sceneAction
///
///     var body: some View {
///         Button("Log out") {
///             sceneAction(SessionAction.logout)
///         }
///     }
/// }
/// ```
///
/// The scene is created by ``SwiftUICore/View/sceneActionEnabled()``. An action is delivered to the
/// handlers that exist when it is sent, so a handler that is not in the hierarchy yet does not
/// receive it later.
public struct SceneAction: Sendable {

    private let registry = Registry()

    init() {}

    /// Sends the action to every handler of its type in the scene.
    ///
    /// Nothing happens when there is no handler for the type.
    ///
    /// - Parameter action: The action to send.
    public func callAsFunction<Action: Hashable>(_ action: Action) {
        registry.broadcast(for: Action.self, createIfNeeded: false)?.send(action)
    }
}

extension SceneAction {

    /// Identifies the scene this action belongs to. Copies of a `SceneAction` share the same identity.
    var id: ObjectIdentifier {
        ObjectIdentifier(registry)
    }

    /// The actions of the given type performed on this scene after this call.
    ///
    /// The subscription starts synchronously, when the iterator is created.
    func values<Action: Hashable>(for actionType: Action.Type) -> BroadcastSequence<Action> {
        guard let broadcast = registry.broadcast(for: actionType, createIfNeeded: true) else {
            fatalError("Unreachable: a broadcast is always created on demand")
        }

        return broadcast.values
    }
}

extension SceneAction {

    /// Keeps one `Broadcast` per action type.
    fileprivate final class Registry: @unchecked Sendable {

        private let lock = Lock()
        private var broadcasts: [ObjectIdentifier: Any] = [:]

        func broadcast<Action>(for actionType: Action.Type, createIfNeeded: Bool) -> Broadcast<Action>? {
            lock.withLock {
                let key = ObjectIdentifier(actionType)

                if let broadcast = broadcasts[key] as? Broadcast<Action> {
                    return broadcast
                }

                guard createIfNeeded else {
                    return nil
                }

                let broadcast = Broadcast<Action>()
                broadcasts[key] = broadcast
                return broadcast
            }
        }
    }
}
