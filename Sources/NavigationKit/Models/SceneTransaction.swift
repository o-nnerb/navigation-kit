// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Combine
import Foundation
import SwiftAsyncStream

/// A type representing a scene transaction that can be observed by a view
/// and trigger a destination action.
public struct SceneTransaction<Destination> {

    private let seed: Seed
    private let broadcast = Broadcast<Destination>()

    // Kept only to serve the deprecated `publisher`. Remove together with it.
    private let subject = PassthroughSubject<Destination, Never>()

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

    /// A publisher that emits a destination value when the transaction is triggered.
    @available(
        *,
        deprecated,
        message: "Iterate `values` instead. `publisher` will be removed in a future major release."
    )
    public var publisher: AnyPublisher<Destination, Never> {
        subject.eraseToAnyPublisher()
    }

    /// Triggers the transaction's destination action.
    public func callAsFunction(_ destination: Destination) {
        broadcast.send(destination)
        subject.send(destination)
    }
}

extension SceneTransaction where Destination: Sendable {

    /// An asynchronous sequence that emits a destination value each time the transaction is triggered.
    ///
    /// Every iterator receives every value triggered after it was created (the subscription starts
    /// when `makeAsyncIterator()` is called, not at the first `next()`). Cancelling the task that
    /// iterates ends the sequence.
    ///
    /// ```swift
    /// .task {
    ///     for await destination in transaction.values {
    ///         // ...
    ///     }
    /// }
    /// ```
    public var values: AnyAsyncSequence<Destination> {
        broadcast.values.eraseToAnyAsyncSequence()
    }
}
