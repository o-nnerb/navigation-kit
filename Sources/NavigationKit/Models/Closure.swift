// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

/// A closure that can be compared and hashed, so it can be part of a `Hashable` model.
///
/// Swift closures are not `Equatable`. A model that carries a callback, such as the scene of a screen
/// that reports a result back to the screen that opened it, can hold a `Closure` and still be used as a
/// navigation item. Two values are equal only if one is a copy of the other. Two closures created from
/// the same code are different.
///
/// The input is a single value of type `Input`. For a closure with several parameters, make `Input` a
/// tuple and call it with the arguments directly, up to eight.
///
/// Usage:
///
/// ```swift
/// let closure: Closure<Int, String> = .closure { input in
///    "The input is \(input)"
/// }
///
/// let output = closure(10) // output is "The input is 10"
/// ```
public struct Closure<Input, Output> {

    private let closure: (Input) -> Output
    private let seed: Seed

    fileprivate init(_ closure: @escaping (Input) -> Output) {
        self.closure = closure
        self.seed = .init()
    }

    /// Calls the closure with the specified input and returns the output.
    ///
    /// - Parameter input: The input value to pass to the closure.
    /// - Returns: The output value produced by the closure.
    public func callAsFunction(_ input: Input) -> Output {
        closure(input)
    }
}

extension Closure where Input == Void {

    /// Calls the closure with no input and returns the output.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction() -> Output {
        closure(())
    }
}

// swiftlint:disable identifier_name function_parameter_count
extension Closure {

    /// Calls the closure with two arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1>(
        _ p0: P0,
        _ p1: P1
    ) -> Output where Input == (P0, P1) {
        closure((p0, p1))
    }

    /// Calls the closure with three arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1, P2>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2
    ) -> Output where Input == (P0, P1, P2) {
        closure((p0, p1, p2))
    }

    /// Calls the closure with four arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1, P2, P3>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3
    ) -> Output where Input == (P0, P1, P2, P3) {
        closure((p0, p1, p2, p3))
    }

    /// Calls the closure with five arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1, P2, P3, P4>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4
    ) -> Output where Input == (P0, P1, P2, P3, P4) {
        closure((p0, p1, p2, p3, p4))
    }

    /// Calls the closure with six arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1, P2, P3, P4, P5>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4,
        _ p5: P5
    ) -> Output where Input == (P0, P1, P2, P3, P4, P5) {
        closure((p0, p1, p2, p3, p4, p5))
    }

    /// Calls the closure with seven arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1, P2, P3, P4, P5, P6>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4,
        _ p5: P5,
        _ p6: P6
    ) -> Output where Input == (P0, P1, P2, P3, P4, P5, P6) {
        closure((p0, p1, p2, p3, p4, p5, p6))
    }

    /// Calls the closure with eight arguments, which make its tuple input.
    ///
    /// - Returns: The output value produced by the closure.
    public func callAsFunction<P0, P1, P2, P3, P4, P5, P6, P7>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4,
        _ p5: P5,
        _ p6: P6,
        _ p7: P7
    ) -> Output where Input == (P0, P1, P2, P3, P4, P5, P6, P7) {
        closure((p0, p1, p2, p3, p4, p5, p6, p7))
    }
}

extension Closure: Equatable {

    public static func == (_ lhs: Closure<Input, Output>, _ rhs: Closure<Input, Output>) -> Bool {
        lhs.seed === rhs.seed
    }

    public static func == <RightInput, RightOutput>(
        _ lhs: Closure<Input, Output>,
        _ rhs: Closure<RightInput, RightOutput>
    ) -> Bool {
        lhs.seed === rhs.seed
    }
}

extension Closure: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(seed))
    }
}

extension Closure {

    /// Creates a closure from the given one.
    ///
    /// Every call creates a different value, even when the closure is the same.
    ///
    /// - Parameter closure: The closure to wrap.
    public static func closure(_ closure: @escaping (Input) -> Output) -> Self {
        .init(closure)
    }
}
