// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

#if !os(macOS)
@MainActor
private struct SceneActionFullScreenCover<Action: Hashable, Scene: Hashable>: ViewModifier {

    @State var presented: Identified<Action>?

    private let onDismiss: (() -> Void)?
    private let reducer: (Action) -> Scene

    init(
        onDismiss: (() -> Void)?,
        reducer: @escaping (Action) -> Scene
    ) {
        self.onDismiss = onDismiss
        self.reducer = reducer
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                FullScreenCoverModifier(
                    presented: $presented,
                    onDismiss: onDismiss,
                    reducer: reducer
                )
            )
            .sceneAction(for: Action.self) {
                presented = .init(item: $0)
            }
    }
}

extension SceneActionFullScreenCover {

    fileprivate struct FullScreenCoverModifier: ViewModifier {

        @Environment(\.sceneAction) var sceneAction
        @Environment(\.viewResolver) var viewResolver

        @Binding var presented: Identified<Action>?

        let onDismiss: (() -> Void)?
        let reducer: (Action) -> Scene

        func body(content: Content) -> some View {
            content
                .fullScreenCover(item: $presented, onDismiss: onDismiss) {
                    viewResolver(reducer($0.item))
                        .environment(\.sceneAction, sceneAction)
                }
        }
    }
}

@MainActor
extension View {

    /// Presents a full-screen cover when an action of the given type is sent on the scene.
    ///
    /// Not available on macOS. The content of the cover is the view registered with ``SwiftUICore/View/viewResolver(for:_:)`` for the
    /// type of the scene that `reducer` returns.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the cover.
    ///    - onDismiss: A closure that runs after the cover is dismissed.
    ///    - reducer: Maps the action to the model of the view to present.
    /// - Returns: A view that presents a cover for each action.
    public func sceneActionFullScreenCover<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        onDismiss: (() -> Void)? = nil,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionFullScreenCover(onDismiss: onDismiss, reducer: reducer))
    }

    /// Presents a full-screen cover when an action of the given type is sent on the scene.
    ///
    /// The action itself is the model resolved with ``SwiftUICore/View/viewResolver(for:_:)``, so a view must
    /// be registered for the action type.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the cover.
    ///    - onDismiss: A closure that runs after the cover is dismissed.
    /// - Returns: A view that presents a cover for each action.
    public func sceneActionFullScreenCover<Action: Hashable>(
        for actionType: Action.Type,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        sceneActionFullScreenCover(
            for: actionType,
            onDismiss: onDismiss,
            reducer: { $0 }
        )
    }
}
#endif
