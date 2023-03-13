/*
 See LICENSE for this package's licensing information.
*/

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
            .modifier(FullScreenCoverModifier(
                presented: $presented,
                reducer: reducer
            ))
            .sceneAction(for: Action.self) {
                presented = .init(item: $0)
            }
    }
}

private extension SceneActionFullScreenCover {

    struct FullScreenCoverModifier: ViewModifier {

        @Environment(\._sceneAction) var sceneAction
        @Environment(\.viewResolver) var viewResolver

        @Binding var presented: Identified<Action>?

        let reducer: (Action) -> Scene

        func body(content: Content) -> some View {
            content
                .sheet(item: $presented) {
                    viewResolver(reducer($0.item))
                        .environment(\._sceneAction, sceneAction)
                }
        }
    }
}

@MainActor
extension View {

    /**
     Presents a full-screen cover when an action of the specified type is received.
     - Parameters:
        - actionType: The type of action to listen for.
        - reducer: The reducer function that will be used to update the scene's state based on the action received.
     - Returns: A view that will present a full-screen cover when the specified action is received.
     */
    public func sceneActionFullScreenCover<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionFullScreenCover(reducer: reducer))
    }

    /**
     Presents a full-screen cover when an action of the specified type is received.
     - Parameter actionType: The type of action to listen for.
     - Returns: A view that will present a full-screen cover when the specified action is received.
     */
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
