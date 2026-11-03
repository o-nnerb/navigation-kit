// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// Changes the items of the navigation stack the view belongs to.
///
/// It takes the place of the `NavigationPath` binding: instead of owning the path, the views ask
/// the stack to push or pop. Get it from the `navigationAction` environment value, which is set by
/// ``NKNavigationStack`` and ``NKNavigationSplitView``. Each item pushed is shown by the view
/// registered for its type with ``SwiftUICore/View/nkNavigationDestination(for:destination:)``.
///
/// ```swift
/// struct MainView: View {
///     @Environment(\.navigationAction) var navigationAction
///
///     var body: some View {
///         Button("Submit") {
///             navigationAction.append(UserModel())
///         }
///     }
/// }
/// ```
///
/// Items need to be `Hashable`. The ones that are also `Codable` can be saved with ``codable`` and
/// restored through the initializer of ``NKNavigationStack``.
@MainActor
public struct NavigationAction {

    private let state: NavigationStateProtocol
    private let resolver: [ObjectIdentifier: @MainActor (AnyHashable) -> NavigationPerform<AnyHashable>?]

    private init(
        state: NavigationStateProtocol,
        resolver: [ObjectIdentifier: @MainActor (AnyHashable) -> NavigationPerform<AnyHashable>?]
    ) {
        self.state = state
        self.resolver = resolver
    }

    init(_ state: NavigationStateProtocol) {
        self.init(state: state, resolver: [:])
    }
}

extension NavigationAction {

    /// Replaces the whole stack with the items, the last one being the one on top.
    ///
    /// Before iOS 16, tvOS 16 and macOS 13 the items are pushed one at a time, each after the previous
    /// transition finishes.
    ///
    /// - Parameter items: The items to set in the navigation stack.
    public func setItems<Item: Hashable & Sendable>(_ items: [Item]) {
        if performIfNeeded(for: .setItems(items)) != nil {
            return
        }

        state.setItems(items)
    }

    /// Replaces the whole stack with the `Codable` items, the last one being the one on top.
    ///
    /// Use this overload for items that must survive ``codable``. A stack that contains an item that
    /// is not `Codable` has no representation.
    ///
    /// - Parameter items: The items to set in the navigation stack.
    public func setItems<Item: Hashable & Codable & Sendable>(_ items: [Item]) {
        if performIfNeeded(for: .setItems(items)) != nil {
            return
        }

        state.setItems(items)
    }

    /// Pushes the item on top of the stack.
    ///
    /// - Parameter item: The item to append.
    public func append<Item: Hashable & Sendable>(_ item: Item) {
        if performIfNeeded(for: .append(item)) != nil {
            return
        }

        state.append(item)
    }

    /// Pushes the `Codable` item on top of the stack.
    ///
    /// Use this overload for items that must survive ``codable``.
    ///
    /// - Parameter item: The item to append.
    public func append<Item: Hashable & Codable & Sendable>(_ item: Item) {
        if performIfNeeded(for: .append(item)) != nil {
            return
        }

        state.append(item)
    }

    /// Pops back to the screen before the item: the item and everything pushed after it are removed.
    ///
    /// Nothing happens when the item is not in the stack.
    ///
    /// - Parameter item: The item to remove.
    public func removeIncluding<Item: Hashable & Sendable>(_ item: Item) {
        if performIfNeeded(for: .removeIncluding(item)) != nil {
            return
        }

        state.removeIncluding(item)
    }

    /// Pops back to the item: everything pushed after it is removed and the item stays on top.
    ///
    /// Nothing happens when the item is not in the stack.
    ///
    /// - Parameter item: The item to go back to.
    public func removeUntil<Item: Hashable & Sendable>(_ item: Item) {
        if performIfNeeded(for: .removeUntil(item)) != nil {
            return
        }

        state.removeUntil(item)
    }

    /// Removes the item from the middle of the stack, keeping the others in order.
    ///
    /// Nothing happens when the item is not in the stack.
    ///
    /// - Parameter item: The item to remove.
    public func remove<Item: Hashable & Sendable>(_ item: Item) {
        if performIfNeeded(for: .remove(item)) != nil {
            return
        }

        state.remove(item)
    }

    /// Removes all items from the navigation stack.
    public func removeAll() {
        state.removeAll()
    }

    /// Removes the last item from the navigation stack.
    public func removeLast() {
        state.removeLast()
    }

    /// Removes the `k` items on top of the stack.
    ///
    /// - Parameter k: The number of items to remove.
    public func removeLast(_ k: Int) {
        state.removeLast(k)
    }

    /// The number of items in the navigation stack.
    public var count: Int {
        state.count
    }

    /// A value that describes the contents of this path in a serializable format.
    ///
    /// It is `nil` when an item in the stack is not `Codable`. Encode the value, for example with
    /// `JSONEncoder`, and pass it back to ``NKNavigationStack`` to restore the stack.
    public var codable: CodableRepresentation? {
        state.codable
    }

    /// Returns whether the item is in the stack.
    ///
    /// - Parameter item: The item to look for.
    public func contains<Item: Hashable & Sendable>(_ item: Item) -> Bool {
        guard case .contains(let item)? = performIfNeeded(for: .contains(item)) else {
            return state.contains(item)
        }

        return state.contains(item)
    }
}

extension NavigationAction {

    func resolver<Item: Hashable>(
        for itemType: Item.Type,
        closure: @escaping @MainActor (NavigationPerform<Item>) -> NavigationPerform<AnyHashable>?
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

    fileprivate func performIfNeeded<Item: Hashable & Sendable>(
        for action: NavigationPerform<Item>
    ) -> NavigationPerform<AnyHashable>? {
        guard let closure = resolver[.init(Item.self)] else {
            return nil
        }

        return closure(action)
    }
}
