// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

private struct SceneActionModifier<Action: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction
    @State private var subscription = SceneActionSubscription<Action>()

    private let action: @MainActor (Action) -> Void

    init(_ action: @escaping @MainActor (Action) -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        let subscription = subscribe()

        content
            .task(id: sceneAction.id) { @MainActor [subscription, sceneAction, action] in
                await subscription.consume(sceneAction, perform: action)
            }
    }

    /// Subscribes while the view is being built, so an action performed between the view being
    /// built and its `task` starting is not lost.
    private func subscribe() -> SceneActionSubscription<Action> {
        subscription.prepare(for: sceneAction)
        return subscription
    }
}

/// Bridges a scene's async action stream to a view modifier.
@MainActor
final class SceneActionSubscription<Action: Hashable> {

    typealias Iterator = BroadcastSequence<Action>.AsyncIterator

    private var pending: (id: ObjectIdentifier, iterator: Iterator)?
    private var consumer = 0
    private var isConsuming = false

    func prepare(for sceneAction: SceneAction) {
        // A running consumer already owns a subscription. A second one would only buffer
        // actions that were already handled and replay them the next time the view appears.
        guard !isConsuming, pending?.id != sceneAction.id else {
            return
        }

        pending = (sceneAction.id, sceneAction.values(for: Action.self).makeAsyncIterator())
    }

    func consume(
        _ sceneAction: SceneAction,
        perform action: @MainActor (Action) -> Void
    ) async {
        var iterator: Iterator

        if let pending, pending.id == sceneAction.id {
            iterator = pending.iterator
        } else {
            iterator = sceneAction.values(for: Action.self).makeAsyncIterator()
        }

        pending = nil
        consumer += 1
        isConsuming = true

        let current = consumer
        defer {
            if consumer == current {
                isConsuming = false
            }
        }

        while let value = await iterator.next() {
            action(value)
        }
    }
}

extension View {

    /// Adds a scene action to the view.
    ///
    /// Use `sceneAction` to add an action to the view that should trigger when a specific
    /// type of `Action` is dispatched on the scene.
    ///
    /// - Parameter
    ///    - actionType: The type of the `Action` that should trigger the action.
    ///    - action: A closure that executes when the `actionType` is dispatched.
    ///
    /// - Returns: A modified version of this view that includes the action.
    public func sceneAction<Action: Hashable>(
        for actionType: Action.Type,
        perform action: @escaping @MainActor (Action) -> Void
    ) -> some View {
        modifier(SceneActionModifier(action))
    }
}
