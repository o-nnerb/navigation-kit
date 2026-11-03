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

    private func makeEngine() -> NavigationDestinationTransformerModifier<String>.Engine {
        .init(
            navigationAction: navigationAction,
            closure: { transformer, value in
                if let integer = Int(value) {
                    transformer(integer)
                }
            }
        )
    }

    @Test func modifier_whenSetItems_shouldTransformEachOne() async throws {
        // Given
        let navigationAction = makeEngine().build()

        // When
        navigationAction.setItems(["1", "2", "3"])

        // Then
        #expect(navigationAction.count == 3)
        #expect(navigationAction.contains(1))
        #expect(navigationAction.contains(2))
        #expect(navigationAction.contains(3))
    }

    @Test func modifier_whenRemoveUntil_shouldKeepTheTransformedItem() async throws {
        // Given
        let navigationAction = makeEngine().build()
        navigationAction.setItems(["1", "2", "3"])

        // When
        navigationAction.removeUntil("2")

        // Then
        #expect(navigationAction.count == 2)
        #expect(navigationAction.contains(2))
        #expect(!navigationAction.contains(3))
    }

    @Test func modifier_whenRemoveIncluding_shouldRemoveTheTransformedItem() async throws {
        // Given
        let navigationAction = makeEngine().build()
        navigationAction.setItems(["1", "2", "3"])

        // When
        navigationAction.removeIncluding("2")

        // Then
        #expect(navigationAction.count == 1)
        #expect(navigationAction.contains(1))
        #expect(!navigationAction.contains(2))
    }

    @Test func modifier_whenRemove_shouldRemoveOnlyTheTransformedItem() async throws {
        // Given
        let navigationAction = makeEngine().build()
        navigationAction.setItems(["1", "2", "3"])

        // When
        navigationAction.remove("2")

        // Then
        #expect(navigationAction.count == 2)
        #expect(navigationAction.contains(1))
        #expect(!navigationAction.contains(2))
        #expect(navigationAction.contains(3))
    }

    @Test func modifier_whenClosureDoesNotTransform_shouldKeepTheItemAsItCame() async throws {
        // Given
        let navigationAction = makeEngine().build()

        // When
        navigationAction.append("not a number")

        // Then
        #expect(navigationAction.contains("not a number"))
        #expect(navigationAction.count == 1)
    }
}
