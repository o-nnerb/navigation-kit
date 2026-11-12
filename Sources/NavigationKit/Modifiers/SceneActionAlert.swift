// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

@MainActor
private struct SceneActionAlert<Action: Hashable, Actions: View, Message: View>: ViewModifier {

    // The action stays after the alert is dismissed, which is harmless: the alert only appears
    // while `isPresented` is `true`, and the next action replaces it.
    @State var action: Action?
    @State var isPresented = false

    private let title: (Action) -> Text
    private let actions: (Action) -> Actions
    private let message: ((Action) -> Message)?

    init(
        title: @escaping (Action) -> Text,
        actions: @escaping (Action) -> Actions,
        message: ((Action) -> Message)?
    ) {
        self.title = title
        self.actions = actions
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                AlertModifier(
                    isPresented: $isPresented,
                    action: action,
                    title: title,
                    actions: actions,
                    message: message
                )
            )
            .sceneAction(for: Action.self) {
                action = $0
                isPresented = true
            }
    }
}

extension SceneActionAlert {

    fileprivate struct AlertModifier: ViewModifier {

        @Binding var isPresented: Bool

        let action: Action?
        let title: (Action) -> Text
        let actions: (Action) -> Actions
        let message: ((Action) -> Message)?

        // The system asks for the title even when nothing is presented.
        private var currentTitle: Text {
            action.map(title) ?? Text(verbatim: "")
        }

        @ViewBuilder
        func body(content: Content) -> some View {
            if let message {
                content
                    .alert(
                        currentTitle,
                        isPresented: $isPresented,
                        presenting: action,
                        actions: actions,
                        message: message
                    )
            } else {
                content
                    .alert(
                        currentTitle,
                        isPresented: $isPresented,
                        presenting: action,
                        actions: actions
                    )
            }
        }
    }
}

@MainActor
extension View {

    /// Presents an alert when an action of the given type is sent on the scene.
    ///
    /// The alert is drawn by the system, so its content is described the same way as in SwiftUI's
    /// `alert`: a title, the buttons and, optionally, a message. Each closure receives the action
    /// that was sent. A button that only calls ``SwiftUICore/EnvironmentValues/sceneAction`` keeps
    /// the alert decoupled from whoever handles the result.
    ///
    /// ```swift
    /// ContentView()
    ///     .sceneActionAlert(for: DeleteAction.self) { action in
    ///         Text("Delete \(action.name)?")
    ///     } actions: { action in
    ///         Button("Delete", role: .destructive) { store.delete(action.id) }
    ///         Button("Cancel", role: .cancel) { }
    ///     } message: { action in
    ///         Text("This can't be undone.")
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the alert.
    ///    - title: The title of the alert for the action.
    ///    - actions: The buttons of the alert for the action.
    ///    - message: The message of the alert for the action.
    ///
    /// - Returns: A view that presents an alert for each action.
    public func sceneActionAlert<Action: Hashable, Actions: View, Message: View>(
        for actionType: Action.Type,
        title: @escaping (Action) -> Text,
        @ViewBuilder actions: @escaping (Action) -> Actions,
        @ViewBuilder message: @escaping (Action) -> Message
    ) -> some View {
        modifier(
            SceneActionAlert(
                title: title,
                actions: actions,
                message: message
            )
        )
    }

    /// Presents an alert without a message when an action of the given type is sent on the scene.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the alert.
    ///    - title: The title of the alert for the action.
    ///    - actions: The buttons of the alert for the action.
    ///
    /// - Returns: A view that presents an alert for each action.
    public func sceneActionAlert<Action: Hashable, Actions: View>(
        for actionType: Action.Type,
        title: @escaping (Action) -> Text,
        @ViewBuilder actions: @escaping (Action) -> Actions
    ) -> some View {
        modifier(
            SceneActionAlert<Action, Actions, EmptyView>(
                title: title,
                actions: actions,
                message: nil
            )
        )
    }
}
