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
        // The subscription lives as long as the view's state, not as long as the view is on screen,
        // so a covered view (root of a stack with a destination on top, hidden tab) keeps receiving.
        subscription.update(sceneAction: sceneAction, perform: action)

        // SwiftUI does not evaluate this body when it returns `content` untouched (observed on macOS and
        // iOS hosting views), so the no-op `onAppear` makes the modifier visible to the view graph.
        return content.onAppear(perform: nil)
    }
}

/// Bridges a scene's async action stream to a view modifier.
///
/// Subscribes synchronously, the first time `update(sceneAction:perform:)` is called (while the
/// view's `body` is evaluated), and consumes the stream from a long-lived task until the
/// subscription is released, which happens when the view leaves the hierarchy. Appearing and
/// disappearing have no effect on it.
@MainActor
final class SceneActionSubscription<Action: Hashable> {

    /// Cancels the task when released. Plain `deinit` on a `Sendable` box, so releasing the
    /// subscription from any context cancels the consumer without needing an isolated `deinit`.
    private final class Consumer: Sendable {

        let task: Task<Void, Never>

        init(_ task: Task<Void, Never>) {
            self.task = task
        }

        deinit {
            task.cancel()
        }
    }

    private var sceneActionID: ObjectIdentifier?
    private var consumer: Consumer?
    private var action: (@MainActor (Action) -> Void)?

    /// Keeps the subscription attached to `sceneAction` and routes its actions to `action`.
    ///
    /// Safe to call on every `body` evaluation: the handler is replaced by the latest one so the
    /// long-lived consumer never calls a stale closure, and the consumer is only replaced when
    /// the scene changes.
    func update(
        sceneAction: SceneAction,
        perform action: @escaping @MainActor (Action) -> Void
    ) {
        self.action = action

        guard sceneActionID != sceneAction.id else {
            return
        }

        sceneActionID = sceneAction.id

        // Created here, not inside the task: the subscription starts now, so nothing sent from
        // this point on is missed, regardless of when the task gets to run.
        var iterator = sceneAction.values(for: Action.self).makeAsyncIterator()

        // Assigning replaces (and cancels) the consumer of the previous scene.
        consumer = Consumer(
            Task { @MainActor [weak self] in
                while let value = await iterator.next() {
                    self?.action?(value)
                }
            }
        )
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
