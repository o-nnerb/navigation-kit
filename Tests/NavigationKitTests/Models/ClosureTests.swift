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
}
