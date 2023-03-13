/*
 See LICENSE for this package's licensing information.
*/

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
            .modifier(SheetModifier(
                presented: $presented,
                reducer: reducer
            ))
            .sceneAction(for: Action.self) {
                presented = .init(item: $0)
            }
    }
}

private extension SceneActionSheet {

    struct SheetModifier: ViewModifier {

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

    /**
     Presents an action sheet for a given action type, and maps the selected action to a scene.

     - Parameters:
        - actionType: A type of action that will be presented in the action sheet.
        - reducer: A closure that maps the selected action to a scene.

     - Returns: A new view that presents an action sheet.
     */
    public func sceneActionSheet<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionSheet(reducer: reducer))
    }

    /**
     Presents an action sheet for a given action type.

     - Parameter actionType: A type of action that will be presented in the action sheet.

     - Returns: A new view that presents an action sheet.
     */
    public func sceneActionSheet<Action: Hashable>(
        for actionType: Action.Type
    ) -> some View {
        sceneActionSheet(
            for: actionType,
            reducer: { $0 }
        )
    }
}
