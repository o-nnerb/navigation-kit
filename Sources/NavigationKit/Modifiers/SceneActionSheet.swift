//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

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

    public func sceneActionSheet<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionSheet(reducer: reducer))
    }

    public func sceneActionSheet<Action: Hashable>(
        for actionType: Action.Type
    ) -> some View {
        sceneActionSheet(
            for: actionType,
            reducer: { $0 }
        )
    }
}
