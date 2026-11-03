// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

@MainActor
private struct SceneActionSheet<Action: Hashable, Scene: Hashable>: ViewModifier {

    @State var presented: Identified<Action>?

    private let reducer: (Action) -> Scene

    init(reducer: @escaping (Action) -> Scene) {
        self.reducer = reducer
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                SheetModifier(
                    presented: $presented,
                    reducer: reducer
                )
            )
            .sceneAction(for: Action.self) {
                presented = .init(item: $0)
            }
    }
}

extension SceneActionSheet {

    fileprivate struct SheetModifier: ViewModifier {

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

    /// Presents a sheet when an action of the given type is sent on the scene.
    ///
    /// The content of the sheet is the view registered with ``SwiftUICore/View/viewResolver(for:_:)`` for the
    /// type of the scene that `reducer` returns. The sheet is a SwiftUI `sheet`, not an `ActionSheet`.
    ///
    /// ```swift
    /// ContentView()
    ///     .sceneActionSheet(for: SettingsAction.self) { action in
    ///         SettingsScene(section: action.section)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the sheet.
    ///    - reducer: Maps the action to the model of the view to present.
    ///
    /// - Returns: A view that presents a sheet for each action.
    public func sceneActionSheet<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionSheet(reducer: reducer))
    }

    /// Presents a sheet when an action of the given type is sent on the scene.
    ///
    /// The action itself is the model resolved with ``SwiftUICore/View/viewResolver(for:_:)``, so a view must
    /// be registered for the action type.
    ///
    /// - Parameter actionType: The type of the action that presents the sheet.
    ///
    /// - Returns: A view that presents a sheet for each action.
    public func sceneActionSheet<Action: Hashable>(
        for actionType: Action.Type
    ) -> some View {
        sceneActionSheet(
            for: actionType,
            reducer: { $0 }
        )
    }
}
