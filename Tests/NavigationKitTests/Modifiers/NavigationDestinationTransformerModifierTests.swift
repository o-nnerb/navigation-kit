// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

// swiftlint:disable type_name
@MainActor
@Suite struct NavigationDestinationTransformerModifierTests {

    let navigationAction = NavigationAction(FallbackNavigationState())

    @Test func modifier_whenAppendString_shouldContainsString() async throws {
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
        #expect(navigationAction.contains("\(value)"))
    }

    @Test func modifier_whenAppendString_shouldBeInt() async throws {
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
        #expect(navigationAction.contains(value))
    }

    @Test func modifier_whenAppendString_shouldNotContainsOtherValue() async throws {
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
        #expect(!navigationAction.contains(value + 1))
    }
}
