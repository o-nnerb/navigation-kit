//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

@MainActor
struct SceneActionPopover<Action: Hashable, Scene: Hashable>: ViewModifier {

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
            .modifier(PopoverModifier(
                presented: $presented,
                attachmentAnchor: attachmentAnchor,
                arrowEdge: arrowEdge,
                reducer: reducer
            ))
            .sceneAction(for: Action.self) {
                presented = .init(item: $0)
            }
    }
}

private extension SceneActionPopover {

    struct PopoverModifier: ViewModifier {

        @Environment(\._sceneAction) var sceneAction
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
                            .environment(\._sceneAction, sceneAction)
                    }
                )
        }
    }
}

@MainActor
extension View {

    public func sceneActionPopover<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
        arrowEdge: Edge = .top,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionPopover(
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            reducer: reducer
        ))
    }

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
