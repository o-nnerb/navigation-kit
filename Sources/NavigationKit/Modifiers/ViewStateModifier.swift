/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

private struct ViewStateModifier<Object: AnyObject>: ViewModifier {

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

    /**
     Sets the state of the view to active or inactive, based on the given binding.

     - Parameter viewState: A binding to a `ViewState` value that determines
     the state of the view.

     - Returns: A new view that reflects the state of the `viewState` binding.
     */
    public func viewState(_ viewState: Binding<ViewState>) -> some View {
        onAppear {
            viewState.wrappedValue = .active
        }
        .onDisappear {
            viewState.wrappedValue = .inactive
        }
    }

    /**
     Sets the state of the view to active or inactive, based on the given object's key path.

     - Parameters:
        - object: An object that conforms to `AnyObject`.
        - keyPath: A key path that points to a `ViewState` value in the `object`.

     - Returns: A new view that reflects the state of the `ViewState` value pointed to
     by the `keyPath` in the `object`.
     */
    public func viewState<Object: AnyObject>(
        _ object: Object,
        keyPath: WritableKeyPath<Object, ViewState>
    ) -> some View {
        modifier(ViewStateModifier(
            object: object,
            keyPath: keyPath
        ))
    }
}
