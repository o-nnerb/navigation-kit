//
//  File.swift
//  
//
//  Created by Brenno on 02/03/23.
//

import SwiftUI

private struct SceneActionModifier<Action: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction

    private let action: (Action) -> Void

    init(_ action: @escaping (Action) -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onReceive(
                sceneAction.publisher(for: Action.self),
                perform: action
            )
    }
}

extension View {

    public func sceneAction<Action: Hashable>(
        for actionType: Action.Type,
        perform action: @escaping (Action) -> Void
    ) -> some View {
        modifier(SceneActionModifier(action))
    }
}
