/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class ClosureTests: XCTestCase {

    func testClosure_whenParameterIsInt_shouldBeInt() {
        // Given
        var value: Int?
        let closure = Closure<Int, Void>.closure {
            value = $0
        }

        // When
        closure(1)

        // Then
        XCTAssertEqual(value, 1)
    }

    func testClosure_whenParameterIsVoid_shouldExecute() {
        // Given
        var wasCalled = false
        let closure = Closure<Void, Void>.closure {
            wasCalled = true
        }

        // When
        closure()

        // Then
        XCTAssertTrue(wasCalled)
    }

    func testClosure_whenParameterIsTuple_shouldBeEqual() {
        // Given
        var value: (Int, Bool, String)?
        let closure = Closure<(Int, Bool, String), Void>.closure {
            value = $0
        }

        // When
        closure(.zero, true, "Hello World")

        // Then
        XCTAssertEqual(value?.0, .zero)
        XCTAssertEqual(value?.1, true)
        XCTAssertEqual(value?.2, "Hello World")
    }

    func testClosure_whenParameterIsVoid_shouldReturnBool() {
        // Given
        let closure = Closure<Void, Bool>.closure {
            return true
        }

        // When
        let value = closure()

        // Then
        XCTAssertTrue(value)
    }
}
