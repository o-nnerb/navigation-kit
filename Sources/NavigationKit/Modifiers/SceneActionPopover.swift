// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

#if !os(watchOS) && !os(tvOS)
@MainActor
private struct SceneActionPopover<Action: Hashable, Scene: Hashable>: ViewModifier {

    @State var presented: Identified<Action>?

    private let attachmentAnchor: PopoverAttachmentAnchor
    private let arrowEdge: Edge
    private let reducer: (Action) -> Scene

    init(
        attachmentAnchor: PopoverAttachmentAnchor,
        arrowEdge: Edge,
        reducer: @escaping (Action) -> Scene
    ) {
        self.attachmentAnchor = attachmentAnchor
        self.arrowEdge = arrowEdge
        self.reducer = reducer
    }

    func body(content: Content) -> some View {
        content
            .modifier(
                PopoverModifier(
                    presented: $presented,
                    attachmentAnchor: attachmentAnchor,
                    arrowEdge: arrowEdge,
                    reducer: reducer
                )
            )
            .sceneAction(for: Action.self) {
                presented = .init(item: $0)
            }
    }
}

extension SceneActionPopover {

    fileprivate struct PopoverModifier: ViewModifier {

        @Environment(\.sceneAction) var sceneAction
        @Environment(\.viewResolver) var viewResolver

        @Binding var presented: Identified<Action>?

        let attachmentAnchor: PopoverAttachmentAnchor
        let arrowEdge: Edge
        let reducer: (Action) -> Scene

        func body(content: Content) -> some View {
            content
                .popover(
                    item: $presented,
                    attachmentAnchor: attachmentAnchor,
                    arrowEdge: arrowEdge,
                    content: {
                        viewResolver(reducer($0.item))
                            .environment(\.sceneAction, sceneAction)
                    }
                )
        }
    }
}

@MainActor
extension View {

    /// Presents a popover when an action of the given type is sent on the scene.
    ///
    /// Not available on tvOS and watchOS. The content of the popover is the view registered with
    /// ``SwiftUICore/View/viewResolver(for:_:)`` for the type of the scene that `reducer` returns.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the popover.
    ///    - attachmentAnchor: The anchor to which the popover is attached.
    ///    - arrowEdge: The edge on which the popover's arrow is placed.
    ///    - reducer: Maps the action to the model of the view to present.
    ///
    /// - Returns: A view that presents a popover for each action.
    public func sceneActionPopover<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge = .top,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(
            SceneActionPopover(
                attachmentAnchor: attachmentAnchor,
                arrowEdge: arrowEdge,
                reducer: reducer
            )
        )
    }

    /// Presents a popover when an action of the given type is sent on the scene.
    ///
    /// The action itself is the model resolved with ``SwiftUICore/View/viewResolver(for:_:)``, so a view must
    /// be registered for the action type.
    ///
    /// - Parameters:
    ///    - actionType: The type of the action that presents the popover.
    ///    - attachmentAnchor: The anchor to which the popover is attached.
    ///    - arrowEdge: The edge on which the popover's arrow is placed.
    ///
    /// - Returns: A view that presents a popover for each action.
    public func sceneActionPopover<Action: Hashable>(
        for actionType: Action.Type,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge = .top
    ) -> some View {
        sceneActionPopover(
            for: actionType,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            reducer: { $0 }
        )
    }
}
#endif
