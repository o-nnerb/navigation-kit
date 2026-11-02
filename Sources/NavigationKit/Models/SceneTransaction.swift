// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation
import SwiftAsyncStream

/// A type representing a scene transaction that can be observed by a view
/// and trigger a destination action.
///
/// Observe a transaction by iterating its ``values``, for example from a view's `task`:
///
/// ```swift
/// .task {
///     for await destination in transaction.values {
///         // ...
///     }
/// }
/// ```
public struct SceneTransaction<Destination: Sendable>: Sendable {

    private let seed: Seed
    private let broadcast = Broadcast<Destination>()

    /// Initializes a new transaction.
    public init() {
        self.seed = Seed()
    }
}

extension SceneTransaction: Hashable {

    /// Checks if two transactions are equal.
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.seed == rhs.seed
    }

    /// Hashes the transaction's contents into a hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(seed)
    }
}

extension SceneTransaction {

    /// An asynchronous sequence that emits a destination value each time the transaction is triggered.
    ///
    /// Every iterator receives every value triggered after it was created (the subscription starts
    /// when `makeAsyncIterator()` is called, not at the first `next()`). Cancelling the task that
    /// iterates ends the sequence.
    public var values: AnyAsyncSequence<Destination> {
        broadcast.values.eraseToAnyAsyncSequence()
    }

    /// Triggers the transaction's destination action.
    public func callAsFunction(_ destination: Destination) {
        broadcast.send(destination)
    }
}
