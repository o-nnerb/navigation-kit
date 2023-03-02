//
//  File.swift
//  
//
//  Created by Brenno on 02/03/23.
//

import SwiftUI

private struct ViewStateModifier<Object: ObservableObject>: ViewModifier {

    @State var viewState: ViewState = .inactive

    private let object: Object
    private let keyPath: WritableKeyPath<Object, ViewState>

    init(
        object: Object,
        keyPath: WritableKeyPath<Object, ViewState>
    ) {
        self.object = object
        self.keyPath = keyPath
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                update(.active, object)
            }
            .onDisappear {
                update(.inactive, object)
            }
            .onChange(of: Box(object: object)) {
                update(viewState, $0.object)
            }
    }
}

extension ViewStateModifier {

    struct Box: Equatable {
        let object: Object

        static func == (_ lhs: Self, _ rhs: Self) -> Bool {
            lhs.object === rhs.object
        }
    }

    func update(_ viewState: ViewState, _ object: Object) {
        var object = object
        self.viewState = viewState
        object[keyPath: keyPath] = viewState
    }
}

extension View {

    public func viewState(_ viewState: Binding<ViewState>) -> some View {
        onAppear {
            viewState.wrappedValue = .active
        }
        .onDisappear {
            viewState.wrappedValue = .inactive
        }
    }

    public func viewState<Object: ObservableObject>(
        _ object: Object,
        keyPath: WritableKeyPath<Object, ViewState>
    ) -> some View {
        modifier(ViewStateModifier(
            object: object,
            keyPath: keyPath
        ))
    }
}
