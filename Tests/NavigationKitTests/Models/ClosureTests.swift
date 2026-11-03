// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@Suite struct ClosureTests {

    @Test func closure_whenParameterIsInt_shouldBeInt() {
        // Given
        var value: Int?
        let closure = Closure<Int, Void>.closure {
            value = $0
        }

        // When
        closure(1)

        // Then
        #expect(value == 1)
    }

    @Test func closure_whenParameterIsVoid_shouldExecute() {
        // Given
        var wasCalled = false
        let closure = Closure<Void, Void>.closure {
            wasCalled = true
        }

        // When
        closure()

        // Then
        #expect(wasCalled)
    }

    @Test func closure_whenParameterIsTuple_shouldBeEqual() {
        // Given
        var value: (Int, Bool, String)?
        let closure = Closure<(Int, Bool, String), Void>.closure {
            value = $0
        }

        // When
        closure(.zero, true, "Hello World")

        // Then
        #expect(value?.0 == .zero)
        #expect(value?.1 == true)
        #expect(value?.2 == "Hello World")
    }

    @Test func closure_whenParameterIsVoid_shouldReturnBool() {
        // Given
        let closure = Closure<Void, Bool>.closure {
            true
        }

        // When
        let value = closure()

        // Then
        #expect(value)
    }

    @Test func closure_whenCalledWithTwoArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int), Int>.closure { $0.0 + $0.1 }

        // When
        let value = closure(1, 2)

        // Then
        #expect(value == 3)
    }

    @Test func closure_whenCalledWithThreeArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int, Int), Int>.closure { $0.0 + $0.1 + $0.2 }

        // When
        let value = closure(1, 2, 3)

        // Then
        #expect(value == 6)
    }

    @Test func closure_whenCalledWithFourArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int, Int, Int), [Int]>.closure { [$0.0, $0.1, $0.2, $0.3] }

        // When
        let value = closure(1, 2, 3, 4)

        // Then
        #expect(value == [1, 2, 3, 4])
    }

    @Test func closure_whenCalledWithFiveArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int, Int, Int, Int), [Int]>.closure {
            [$0.0, $0.1, $0.2, $0.3, $0.4]
        }

        // When
        let value = closure(1, 2, 3, 4, 5)

        // Then
        #expect(value == [1, 2, 3, 4, 5])
    }

    @Test func closure_whenCalledWithSixArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int, Int, Int, Int, Int), [Int]>.closure {
            [$0.0, $0.1, $0.2, $0.3, $0.4, $0.5]
        }

        // When
        let value = closure(1, 2, 3, 4, 5, 6)

        // Then
        #expect(value == [1, 2, 3, 4, 5, 6])
    }

    @Test func closure_whenCalledWithSevenArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int, Int, Int, Int, Int, Int), [Int]>.closure {
            [$0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6]
        }

        // When
        let value = closure(1, 2, 3, 4, 5, 6, 7)

        // Then
        #expect(value == [1, 2, 3, 4, 5, 6, 7])
    }

    @Test func closure_whenCalledWithEightArguments_shouldReceiveTheTuple() {
        // Given
        let closure = Closure<(Int, Int, Int, Int, Int, Int, Int, Int), [Int]>.closure {
            [$0.0, $0.1, $0.2, $0.3, $0.4, $0.5, $0.6, $0.7]
        }

        // When
        let value = closure(1, 2, 3, 4, 5, 6, 7, 8)

        // Then
        #expect(value == [1, 2, 3, 4, 5, 6, 7, 8])
    }

    @Test func closure_whenCopied_shouldBeEqualAndShareTheHash() {
        // Given
        let closure = Closure<Int, Int>.closure { $0 }

        // When
        let copy = closure

        // Then
        #expect(closure == copy)
        #expect(closure.hashValue == copy.hashValue)
    }

    @Test func closure_whenCreatedFromTheSameCode_shouldBeDifferent() {
        // Given
        let make = { Closure<Int, Int>.closure { $0 } }

        // When
        let first = make()
        let second = make()

        // Then
        #expect(first != second)
        #expect(Set([first, second]).count == 2)
    }

    @Test func closure_whenInputAndOutputTypesDiffer_shouldCompareBySeed() {
        // Given
        let integer = Closure<Int, Int>.closure { $0 }
        let string = Closure<String, String>.closure { $0 }

        // Then
        #expect(integer == integer)
        #expect(!(integer == string))
    }
}
