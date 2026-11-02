// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftAsyncStream
import SwiftUI

/// A type that represents an action that can be performed on a scene.
///
/// You can use this type to define custom actions that can be triggered on a scene. It takes a generic
/// `Action` parameter that conforms to the `Hashable` protocol.
///
/// You can then call the `callAsFunction` method on an instance of `SceneAction` with an
/// argument of type `Action` to perform the corresponding action available in the scene.
public struct SceneAction: Sendable {

    private let registry = Registry()

    init() {}

    /// Perform the action associated with this `SceneAction`.
    ///
    /// Call this method with an argument of type `Action` to perform the corresponding
    /// action on the scene.
    ///
    /// - Parameter action: The action to perform on the scene.
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
