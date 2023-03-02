//
//  File.swift
//  
//
//  Created by Brenno on 02/03/23.
//

import SwiftUI
import Combine

private struct SceneActionMapper<Action: Hashable, NewAction: Hashable>: ViewModifier {

    @Environment(\.sceneAction) var sceneAction
    private let mapper: (Action) -> NewAction

    init(mapper: @escaping (Action) -> NewAction) {
        self.mapper = mapper
    }

    func body(content: Content) -> some View {
        content
            .sceneAction(for: Action.self) {
                sceneAction(mapper($0))
            }
    }
}

extension View {

    public func sceneActionMap<Action: Hashable, NewAction: Hashable>(
        for actionType: Action.Type,
        _ mapper: @escaping (Action) -> NewAction
    ) -> some View {
        modifier(SceneActionMapper(mapper: mapper))
    }
}

private struct ErrorAction: Hashable {}

private struct ContentErrorAction: Hashable {}

struct SceneActionMapper_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
            .sceneActionMap(for: ErrorAction.self) { _ in
                ContentErrorAction()
            }
            .attachSceneAction()
    }
}

struct ContentView: View {

    @State var receivedAction = false
    @Environment(\.sceneAction) var sceneAction

    var body: some View {
        VStack {
            Text(receivedAction ? "Sim" : "False")
            Button("Press") {
                sceneAction(ErrorAction())
            }
        }
        .sceneAction(for: ContentErrorAction.self) { _ in
            receivedAction = true
        }
    }
}
