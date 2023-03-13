/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

#if !os(watchOS)
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

    /**
     Presents a popover view in response to a certain action.

     - Parameters:
        - actionType: The type of action that will trigger the popover view.
        - attachmentAnchor: The anchor to which the popover view is attached.
        - arrowEdge: The edge on which the popover's arrow is placed.
        - reducer: A function that takes the action as input and returns a hashable scene identifier.

     - Returns: A modified version of the view that presents a popover view when the action is triggered.
     */
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

    /**
     Presents a popover view in response to a certain action.

     - Parameters:
        - actionType: The type of action that will trigger the popover view.
        - attachmentAnchor: The anchor to which the popover view is attached.
        - arrowEdge: The edge on which the popover's arrow is placed.

     - Returns: A modified version of the view that presents a popover view when the action is triggered.
     */
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
