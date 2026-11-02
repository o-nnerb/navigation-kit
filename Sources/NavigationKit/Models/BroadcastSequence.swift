// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftAsyncStream

/// Carries a value across isolation boundaries without checking `Sendable`.
///
/// The library's public API (for example `SceneAction.callAsFunction` and `SceneTransaction`) never
/// required `Sendable` values, so the broadcasting machinery has to transport them as they are.
struct UncheckedSendable<Value>: @unchecked Sendable {
    let value: Value
}

/// A multi-subscriber broadcaster built on `EventSubject`.
///
/// Buffering policy: `.bufferingNewest(256)`. Each subscriber keeps at most the 256 most recent values it
/// has not consumed yet, so a slow consumer that falls further behind skips the oldest ones instead of
/// stalling the sender or growing memory. With no subscriber nothing is retained: values sent while
/// nobody is iterating are dropped, and a new subscriber never receives past values.
///
/// Subscribers only observe the values sent after they start iterating, and iteration starts
/// synchronously when `makeAsyncIterator()` is called (not at the first `next()`), which makes
/// "subscribe, then send, then read" deterministic.
struct Broadcast<Value>: Sendable {

    /// Bounds the elements kept for a subscriber that falls behind. The window must stay bounded:
    /// with no subscriber at all, an unbounded `EventSubject` would retain everything ever sent.
    private static var bufferLimit: Int { 256 }

    private let subject = EventSubject<UncheckedSendable<Value>>(
        bufferingPolicy: .bufferingNewest(Self.bufferLimit)
    )

    func send(_ value: Value) {
        subject.send(.init(value: value))
    }

    var values: BroadcastSequence<Value> {
        .init(subject: subject)
    }
}

/// The sequence of values published by a `Broadcast`.
///
/// Every iterator is an independent subscriber. It starts receiving when `makeAsyncIterator()` is called
/// and follows the `.bufferingNewest(256)` policy described on `Broadcast`.
struct BroadcastSequence<Value>: AsyncSequence {

    typealias Element = Value

    fileprivate let subject: EventSubject<UncheckedSendable<Value>>

    struct AsyncIterator: AsyncIteratorProtocol {

        fileprivate var base: EventSubject<UncheckedSendable<Value>>.AsyncIterator

        mutating func next() async -> Value? {
            await base.next()?.value
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        .init(base: subject.makeAsyncIterator())
    }
}

extension BroadcastSequence: Sendable where Value: Sendable {}
