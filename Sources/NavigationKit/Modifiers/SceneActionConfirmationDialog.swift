// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

@MainActor
private struct SceneActionConfirmationDialog<Action: Hashable, Actions: View, Message: View>: ViewModifier {

    // The action stays after the dialog is dismissed, which is harmless: the dialog only appears
    // while `isPresented` is `true`, and the next action replaces it.
    @State var action: Action?
    @State var isPresented = false

    private let titleVisibility: Visibility
    private let title: (Action) -> Text
    private let actions: (Action) -> Actions
    private let message: ((Action) -> Message)?

    init(
        titleVisibility: Visibility,
        title: @escaping (Action) -> Text,
        actions: @escaping (Action) -> Actions,
        message: ((Action) -> Message)?
    ) {
        self.titleVisibility = titleVisibility
        self.title = title
        self.actions = actions
        self.message = message
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                DialogModifier(
                    isPresented: $isPresented,
                    action: action,
                    titleVisibility: titleVisibility,
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

extension SceneActionConfirmationDialog {

    fileprivate struct DialogModifier: ViewModifier {

        @Binding var isPresented: Bool

        let action: Action?
        let titleVisibility: Visibility
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
                    .confirmationDialog(
                        currentTitle,
                        isPresented: $isPresented,
                        titleVisibility: titleVisibility,
                        presenting: action,
                        actions: actions,
                        message: message
                    )
            } else {
                content
                    .confirmationDialog(
                        currentTitle,
                        isPresented: $isPresented,
                        titleVisibility: titleVisibility,
                        presenting: action,
                        actions: actions
                    )
            }
        }
    }
}

@MainActor
extension View {

    /// Presents a confirmation dialog when an action of the given type is sent on the scene.
    ///
    /// The dialog is drawn by the system, so it is described the same way as in SwiftUI's
    /// `confirmationDialog`: a title, the buttons and, optionally, a message. Each closure receives
    /// the action that was sent.
    ///
    /// ```swift
    /// ContentView()
    ///     .sceneActionConfirmationDialog(for: DeleteAction.self) { action in
    ///         Text("Delete \(action.name)?")
    ///     } actions: { action in
    ///         Button("Delete", role: .destructive) { store.delete(action.id) }
    ///     } message: { action in
    ///         Text("This can't be undone.")
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the dialog.
    ///    - titleVisibility: Whether the title is shown. Defaults to the system's choice.
    ///    - title: The title of the dialog for the action.
    ///    - actions: The buttons of the dialog for the action.
    ///    - message: The message of the dialog for the action.
    ///
    /// - Returns: A view that presents a confirmation dialog for each action.
    public func sceneActionConfirmationDialog<Action: Hashable, Actions: View, Message: View>(
        for actionType: Action.Type,
        titleVisibility: Visibility = .automatic,
        title: @escaping (Action) -> Text,
        @ViewBuilder actions: @escaping (Action) -> Actions,
        @ViewBuilder message: @escaping (Action) -> Message
    ) -> some View {
        modifier(
            SceneActionConfirmationDialog(
                titleVisibility: titleVisibility,
                title: title,
                actions: actions,
                message: message
            )
        )
    }

    /// Presents a confirmation dialog without a message when an action of the given type is sent on
    /// the scene.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the dialog.
    ///    - titleVisibility: Whether the title is shown. Defaults to the system's choice.
    ///    - title: The title of the dialog for the action.
    ///    - actions: The buttons of the dialog for the action.
    ///
    /// - Returns: A view that presents a confirmation dialog for each action.
    public func sceneActionConfirmationDialog<Action: Hashable, Actions: View>(
        for actionType: Action.Type,
        titleVisibility: Visibility = .automatic,
        title: @escaping (Action) -> Text,
        @ViewBuilder actions: @escaping (Action) -> Actions
    ) -> some View {
        modifier(
            SceneActionConfirmationDialog<Action, Actions, EmptyView>(
                titleVisibility: titleVisibility,
                title: title,
                actions: actions,
                message: nil
            )
        )
    }
}
