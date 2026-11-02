// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// The navigation state used where `NavigationStack` is not available (before iOS 16, tvOS 16 and
/// macOS 13). It behaves like `NavigationState`, but keeps the items itself instead of in a
/// `NavigationPath`.
@MainActor
final class FallbackNavigationState: ObservableObject {

    /// How long a push takes to finish. The navigation of the system ignores a push started before
    /// the previous one is done, so the next one waits for it.
    private static let transitionDuration: TimeInterval = 0.55

    private(set) var entries = [NavigationEntry]()

    /// How many items are being shown. It follows `entries`: it goes down at once, and goes up when
    /// no other push is in progress.
    private(set) var displayedCount = 0

    private var lastPendingNavigationItemsHashValue: Int?
    private var lastPush: Date?
    private var reconciliation: Task<Void, Never>?

    init() {}

    /// Applies the items the stack starts with, once for each different value.
    func update(_ pendingItems: PendingNavigationItems?) {
        let hashValue = pendingItems?.hashValue

        guard lastPendingNavigationItemsHashValue != hashValue else {
            return
        }

        lastPendingNavigationItemsHashValue = hashValue
        entries = pendingItems?.entries ?? []
        displayedCount = entries.count
        lastPush = nil
    }

    /// Keeps the first `count` items. Used when the user navigates back.
    func truncate(to count: Int) {
        guard count < entries.count else {
            return
        }

        set(Array(entries.prefix(max(count, 0))))
    }

    private func set(_ entries: [NavigationEntry]) {
        objectWillChange.send()
        self.entries = entries
        reconcile()
    }

    private func reconcile() {
        reconciliation?.cancel()
        reconciliation = nil

        if displayedCount > entries.count {
            displayedCount = entries.count
        }

        guard displayedCount < entries.count else {
            return
        }

        let wait = lastPush.map { Self.transitionDuration - Date().timeIntervalSince($0) } ?? 0

        guard wait > 0 else {
            push()
            return
        }

        reconciliation = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))

            guard !Task.isCancelled else {
                return
            }

            self?.reconcile()
        }
    }

    private func push() {
        objectWillChange.send()
        displayedCount = entries.count
        lastPush = Date()
    }

    private func index<Item: Hashable>(of item: Item) -> Int? {
        entries.firstIndex { $0.hash == item.hashValue }
    }
}

// MARK: - NavigationStateProtocol

extension FallbackNavigationState: NavigationStateProtocol {

    func setItems<Item: Hashable>(_ items: [Item]) {
        set(items.map { NavigationEntry($0) })
    }

    func setItems<Item: Hashable & Codable>(_ items: [Item]) {
        set(items.map { NavigationEntry($0) })
    }

    func append<Item: Hashable>(_ item: Item) {
        set(entries + [NavigationEntry(item)])
    }

    func append<Item: Hashable & Codable>(_ item: Item) {
        set(entries + [NavigationEntry(item)])
    }

    func removeIncluding<Item: Hashable>(_ item: Item) {
        guard let index = index(of: item) else {
            return
        }

        set(Array(entries.prefix(index)))
    }

    func removeUntil<Item: Hashable>(_ item: Item) {
        guard let index = index(of: item) else {
            return
        }

        set(Array(entries.prefix(index + 1)))
    }

    func remove<Item: Hashable>(_ item: Item) {
        guard let index = index(of: item) else {
            return
        }

        var entries = entries
        entries.remove(at: index)

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            set(entries)
        }
    }

    func removeAll() {
        set([])
    }

    func removeLast() {
        removeLast(1)
    }

    func removeLast(_ k: Int) {
        guard k > 0 else {
            return
        }

        set(Array(entries.dropLast(k)))
    }

    var count: Int {
        entries.count
    }

    var codable: NavigationAction.CodableRepresentation? {
        NavigationEntryCodec.encode(entries).map {
            .init(
                navigationPath: $0,
                hashes: entries.map(\.hash)
            )
        }
    }

    func contains<Item: Hashable>(_ item: Item) -> Bool {
        index(of: item) != nil
    }
}
