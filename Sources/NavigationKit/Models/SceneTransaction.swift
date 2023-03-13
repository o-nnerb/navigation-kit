/*
 See LICENSE for this package's licensing information.
*/

import Foundation
import Combine

/// A type representing a scene transaction that can be observed by a view
/// and trigger a destination action.
public struct SceneTransaction<Destination> {

    private let seed: Seed
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
    public var publisher: AnyPublisher<Destination, Never> {
        subject.eraseToAnyPublisher()
    }

    /// Triggers the transaction's destination action.
    public func callAsFunction(_ destination: Destination) {
        subject.send(destination)
    }
}
