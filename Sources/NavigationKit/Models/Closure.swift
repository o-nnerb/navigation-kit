/*
 See LICENSE for this package's licensing information.
*/

import Foundation

/**
 A closure that takes an input of type `Input` and produces an output of type `Output`.

 Usage:

 ```swift
 let closure: Closure<Int, String> = .closure { input in
    "The input is \(input)"
 }

 let output = closure(10) // output is "The input is 10"
 ```
 */
public struct Closure<Input, Output> {

    private let closure: (Input) -> Output
    private let seed: Seed

    fileprivate init(_ closure: @escaping (Input) -> Output) {
        self.closure = closure
        self.seed = .init()
    }

    /**
     Calls the closure with the specified input and returns the output.

     - Parameter input: The input value to pass to the closure.
     - Returns: The output value produced by the closure.
     */
    public func callAsFunction(_ input: Input) -> Output {
        closure(input)
    }
}

extension Closure where Input == Void {

    /**
     Calls the closure with no input and returns the output.

     - Returns: The output value produced by the closure.
     */
    public func callAsFunction() -> Output {
        closure(())
    }
}

// swiftlint:disable identifier_name large_tuple
extension Closure {

    public func callAsFunction<P0, P1>(
        _ p0: P0,
        _ p1: P1
    ) -> Output where Input == (P0, P1) {
        closure((p0, p1))
    }

    public func callAsFunction<P0, P1, P2>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2
    ) -> Output where Input == (P0, P1, P2) {
        closure((p0, p1, p2))
    }

    public func callAsFunction<P0, P1, P2, P3>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3
    ) -> Output where Input == (P0, P1, P2, P3) {
        closure((p0, p1, p2, p3))
    }

    public func callAsFunction<P0, P1, P2, P3, P4>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4
    ) -> Output where Input == (P0, P1, P2, P3, P4) {
        closure((p0, p1, p2, p3, p4))
    }

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

    public static func closure(_ closure: @escaping (Input) -> Output) -> Self {
        .init(closure)
    }
}
