/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI
import Combine

/**
 A type representing an action that modifies the navigation stack.

 You can use this type to add, remove, or manipulate items in the navigation stack of a view.

 ```swift
 struct MainView: View {
     @Environment(\.navigationAction) var navigationAction

     var body: some View {
         Button("Submit") {
             navigationAction.append(UserModel())
         }
     }
 }
 ```
 */
public struct NavigationAction {

    private let state: NavigationState
    private let resolver: [ObjectIdentifier: (AnyHashable) -> Void]

    private init(
        state: NavigationState,
        resolver: [ObjectIdentifier: (AnyHashable) -> Void]
    ) {
        self.state = state
        self.resolver = resolver
    }

    init(_ state: NavigationState) {
        self.init(state: state, resolver: [:])
    }
}

extension NavigationAction {

    /**
     Removes all instances of the specified item and all items after it from the navigation stack.

     - Parameter item: The item to remove.
     */
    public func removeIncluding<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .removeIncluding(item)) {
            return
        }

        state.removeIncluding(item)
    }

    /**
     Removes all items in the navigation stack before the specified item.

     - Parameter item: The item to remove until.
     */
    public func removeUntil<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .removeUntil(item)) {
            return
        }

        state.removeUntil(item)
    }

    /**
     Appends the specified item to the end of the navigation stack.

     - Parameter item: The item to append.
     */
    public func append<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .append(item)) {
            return
        }

        state.append(item)
    }

    /**
     Sets the items in the navigation stack to the specified array of items.

     - Parameter items: The items to set in the navigation stack.
     */
    public func setItems<Item: Hashable>(_ items: [Item]) {
        if performIfNeeded(for: .setItems(items)) {
            return
        }

        state.setItems(items)
    }

    /**
     Removes all items from the navigation stack.
     */
    public func removeAll() {
        state.removeAll()
    }

    /**
     Removes the last item from the navigation stack.
     */
    public func removeLast() {
        state.removeLast()
    }

    /**
     Removes the last k items from the navigation stack.

     - Parameter k: The number of items to remove.
     */
    public func removeLast(_ k: Int) {
        state.removeLast(k)
    }

    /**
     The number of items in the navigation stack.
     */
    public var count: Int {
        state.count
    }
}

extension NavigationAction {

    func resolver<Item: Hashable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationPerform<Item>) -> Void
    ) -> Self {
        guard resolver[.init(itemType)] == nil else {
            print("Resolver for \(itemType) already register")
            return self
        }

        var resolver = resolver
        resolver[.init(itemType)] = {
            guard let item = $0 as? NavigationPerform<Item> else {
                fatalError()
            }

            closure(item)
        }

        return .init(
            state: state,
            resolver: resolver
        )
    }
}

extension NavigationAction {

    fileprivate func performIfNeeded<Item: Hashable>(
        for action: NavigationPerform<Item>
    ) -> Bool {
        guard let closure = resolver[.init(Item.self)] else {
            return false
        }

        closure(action)
        return true
    }
}
