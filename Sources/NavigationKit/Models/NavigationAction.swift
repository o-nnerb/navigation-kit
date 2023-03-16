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

    private let state: NavigationStateProtocol
    private let resolver: [ObjectIdentifier: (AnyHashable) -> NavigationPerform<AnyHashable>?]

    private init(
        state: NavigationStateProtocol,
        resolver: [ObjectIdentifier: (AnyHashable) -> NavigationPerform<AnyHashable>?]
    ) {
        self.state = state
        self.resolver = resolver
    }

    init(_ state: NavigationStateProtocol) {
        self.init(state: state, resolver: [:])
    }
}

extension NavigationAction {

    /**
     Sets the items in the navigation stack to the specified array of items.

     - Parameter items: The items to set in the navigation stack.
     */
    public func setItems<Item: Hashable>(_ items: [Item]) {
        if performIfNeeded(for: .setItems(items)) != nil {
            return
        }

        state.setItems(items)
    }

    /**
     Sets the items in the navigation stack to the specified array of `Codable` items.

     - Parameter items: The items to set in the navigation stack.
     */
    public func setItems<Item: Hashable & Codable>(_ items: [Item]) {
        if performIfNeeded(for: .setItems(items)) != nil {
            return
        }

        state.setItems(items)
    }

    /**
     Appends the specified item to the end of the navigation stack.

     - Parameter item: The item to append.
     */
    public func append<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .append(item)) != nil {
            return
        }

        state.append(item)
    }

    /**
     Appends the specified `Codable` item to the end of the navigation stack.

     - Parameter item: The item to append.
     */
    public func append<Item: Hashable & Codable>(_ item: Item) {
        if performIfNeeded(for: .append(item)) != nil {
            return
        }

        state.append(item)
    }

    /**
     Removes all instances of the specified item and all items after it from the navigation stack.

     - Parameter item: The item to remove.
     */
    public func removeIncluding<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .removeIncluding(item)) != nil {
            return
        }

        state.removeIncluding(item)
    }

    /**
     Removes all items in the navigation stack before the specified item.

     - Parameter item: The item to remove until.
     */
    public func removeUntil<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .removeUntil(item)) != nil {
            return
        }

        state.removeUntil(item)
    }

    /**
     Removes a specific item in the navigation stack.

     - Parameter item: The item to remove.
     */
    public func remove<Item: Hashable>(_ item: Item) {
        if performIfNeeded(for: .remove(item)) != nil {
            return
        }

        state.remove(item)
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

    /// A value that describes the contents of this path in a serializable format.
    public var codable: CodableRepresentation? {
        state.codable
    }

    public func contains<Item: Hashable>(_ item: Item) -> Bool {
        guard case .contains(let item)? = performIfNeeded(for: .contains(item)) else {
            return state.contains(item)
        }

        return state.contains(item)
    }
}

extension NavigationAction {

    func resolver<Item: Hashable>(
        for itemType: Item.Type,
        closure: @escaping (NavigationPerform<Item>) -> NavigationPerform<AnyHashable>?
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

            return closure(item)
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
    ) -> NavigationPerform<AnyHashable>? {
        guard let closure = resolver[.init(Item.self)] else {
            return nil
        }

        return closure(action)
    }
}
