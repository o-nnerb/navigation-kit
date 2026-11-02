// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// The navigation state used where `NavigationStack` is not available (before iOS 16, tvOS 16 and
/// macOS 13). It behaves like `NavigationState`, but keeps the items itself instead of in a
/// `NavigationPath`.
@MainActor
final class FallbackNavigationState: ObservableObject {

    /// The navigation of the system ignores (and reports as dismissed) a push started before the
    /// previous one is done, so the items are shown one at a time.
    ///
    /// When the stack knows its `UINavigationController` (`isReadyForPush`) the next push waits for
    /// that to be idle. Otherwise it is a matter of time: the next item can be pushed this long after
    /// the screen of the previous one appears (which is when its push starts),
    private static let settleDelay: TimeInterval = 0.5

    /// and this long after it was pushed when its screen never appears (for example, a detail that is
    /// not on screen).
    private static let appearTimeout: TimeInterval = 1.5

    /// How often to ask whether the navigation is idle, and for how long before giving up and pushing
    /// anyway (for example, when the detail is not the one being shown).
    private static let readinessInterval: TimeInterval = 0.05
    private static let readinessTimeout: TimeInterval = 3

    /// Tells whether the navigation can start a push, given how many items are being shown: no
    /// transition is in progress and the previous push has landed. Set by the view of the stack
    /// once it finds its `UINavigationController`.
    var isReadyForPush: (@MainActor (_ displayedCount: Int) -> Bool)?

    private(set) var entries = [NavigationEntry]()

    /// How many items are being shown. It follows `entries`: it goes down at once, and goes up one
    /// item each time the previous push is done.
    private(set) var displayedCount = 0

    private var lastPendingNavigationItemsHashValue: Int?
    private var lastPush: Date?
    private var lastAppear: Date?
    private var waitingForReadinessSince: Date?
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
        displayedCount = 0
        lastPush = nil
        lastAppear = nil

        // Called while a view is updated, which cannot publish changes: the first push is deferred.
        reconcile(deferred: true)
    }

    /// Called when the screen of the item at `index` appears, which is when its push starts.
    func didAppear(at index: Int) {
        lastAppear = Date()
        reconcile(deferred: true)
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
        reconcile(deferred: false)
    }

    private func reconcile(deferred: Bool) {
        reconciliation?.cancel()
        reconciliation = nil

        if displayedCount > entries.count {
            displayedCount = entries.count
        }

        guard displayedCount < entries.count else {
            return
        }

        let wait = waitBeforeNextPush()

        if wait <= 0 && !deferred {
            objectWillChange.send()
            displayedCount += 1
            lastPush = Date()
            reconcile(deferred: false)
            return
        }

        reconciliation = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(max(wait, 0) * 1_000_000_000))

            guard !Task.isCancelled else {
                return
            }

            self?.reconcile(deferred: false)
        }
    }

    private func waitBeforeNextPush() -> TimeInterval {
        let now = Date()

        if let isReadyForPush {
            if isReadyForPush(displayedCount) {
                waitingForReadinessSince = nil
                return 0
            }

            let since = waitingForReadinessSince ?? now
            waitingForReadinessSince = since

            if now.timeIntervalSince(since) >= Self.readinessTimeout {
                waitingForReadinessSince = nil
                return 0
            }

            return Self.readinessInterval
        }

        guard let lastPush else {
            return 0
        }

        if let lastAppear, lastAppear >= lastPush {
            return max(Self.settleDelay - now.timeIntervalSince(lastAppear), 0)
        }

        return max(Self.appearTimeout - now.timeIntervalSince(lastPush), 0)
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
