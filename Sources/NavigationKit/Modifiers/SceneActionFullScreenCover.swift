//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

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

    public func sceneActionFullScreenCover<Action: Hashable, Scene: Hashable>(
        for actionType: Action.Type,
        reducer: @escaping (Action) -> Scene
    ) -> some View {
        modifier(SceneActionFullScreenCover(reducer: reducer))
    }

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
