/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

// swiftlint:disable type_name
@MainActor
class NavigationDestinationTransformerModifierTests: XCTestCase {

    var navigationAction: NavigationAction!

    override func setUp() async throws {
        try await super.setUp()
        navigationAction = .init(NavigationState())
    }

    override func tearDown() async throws {
        try await super.tearDown()
        navigationAction = nil
    }

    func testModifier_whenAppendString_shouldContainsString() async throws {
        // Given
        let value = 1

        let engine = NavigationDestinationTransformerModifier<String>.Engine(
            navigationAction: navigationAction,
            closure: { transformer, value in
                if let integer = Int(value) {
                    transformer(integer)
                }
            }
        )

        // When
        let navigationAction = engine.build()
        navigationAction.append("\(value)")

        // Then
        XCTAssertTrue(navigationAction.contains("\(value)"))
    }

    func testModifier_whenAppendString_shouldBeInt() async throws {
        // Given
        let value = 1

        let engine = NavigationDestinationTransformerModifier<String>.Engine(
            navigationAction: navigationAction,
            closure: { transformer, value in
                if let integer = Int(value) {
                    transformer(integer)
                }
            }
        )

        // When
        let navigationAction = engine.build()
        navigationAction.append("\(value)")

        // Then
        XCTAssertTrue(navigationAction.contains(value))
    }

    func testModifier_whenAppendString_shouldNotContainsOtherValue() async throws {
        // Given
        let value = 1

        let engine = NavigationDestinationTransformerModifier<String>.Engine(
            navigationAction: navigationAction,
            closure: { transformer, value in
                if let integer = Int(value) {
                    transformer(integer)
                }
            }
        )

        // When
        let navigationAction = engine.build()
        navigationAction.append("\(value)")

        // Then
        XCTAssertFalse(navigationAction.contains(value + 1))
    }
}
