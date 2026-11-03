// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

#if !os(macOS)
@MainActor
private struct SceneActionFullScreenCover<Action: Hashable, Scene: Hashable>: ViewModifier {

    @State var presented: Identified<Action>?

    private let reducer: (Action) -> Scene

    init(reducer: @escaping (Action) -> Scene) {
        self.reducer = reducer
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                FullScreenCoverModifier(
                    presented: $presented,
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

        let reducer: (Action) -> Scene

        func body(content: Content) -> some View {
            content
                .sheet(item: $presented) {
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
    ///    - reducer: Maps the action to the model of the view to present.
    /// - Returns: A view that presents a cover for each action.
    public func sceneActionFullScreenCover<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionFullScreenCover(reducer: reducer))
    }

    /// Presents a full-screen cover when an action of the given type is sent on the scene.
    ///
    /// The action itself is the model resolved with ``SwiftUICore/View/viewResolver(for:_:)``, so a view must
    /// be registered for the action type.
    ///
    /// - Parameter actionType: The type of the action that presents the cover.
    /// - Returns: A view that presents a cover for each action.
    public func sceneActionFullScreenCover<Action: Hashable>(
        for actionType: Action.Type
    ) -> some View {
        sceneActionFullScreenCover(
            for: actionType,
            reducer: { $0 }
        )
    }
}
#endif
