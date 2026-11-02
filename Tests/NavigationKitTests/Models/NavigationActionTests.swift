// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation
import Testing

@testable import NavigationKit

@MainActor
@Suite struct NavigationActionTests {

    let state = NavigationStateMock()

    @Test func navigationAction_whenEmpty_shouldBeEmpty() async throws {
        // Given
        let navigationAction = NavigationAction(state)

        // Then
        #expect(state.stack.isEmpty)
        #expect(navigationAction.count == .zero)
    }

    @Test func navigationAction_whenAppendItems_shouldContainsItems() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3]

        // When
        for item in items {
            navigationAction.append(item)
        }

        // Then
        #expect(navigationAction.count == items.count)
        #expect(state.stack == items.map(AnyHashable.init))
    }

    @Test func navigationAction_whenAppendItems_shouldRemoveItem() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let item = 1
        let items = [item, 2, 3]

        // When
        for item in items {
            navigationAction.append(item)
        }

        navigationAction.remove(item)

        // Then
        #expect(navigationAction.count == items.count - 1)
        #expect(state.stack == items.filter { $0 != item }.map(AnyHashable.init))
    }

    @Test func navigationAction_whenAppendItems_shouldRemoveUntilItem() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let item = 2
        let items = [1, item, 3, 4]

        // When
        for item in items {
            navigationAction.append(item)
        }

        navigationAction.removeUntil(item)

        // Then
        let index: Int! = items.firstIndex(of: item)

        #expect(index != nil)
        #expect(navigationAction.count == index + 1)
        #expect(state.stack == Array(items[0...index]).map(AnyHashable.init))
    }

    @Test func navigationAction_whenAppendItems_shouldRemoveIncludingItem() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let item = 2
        let items = [1, item, 3, 4]

        // When
        for item in items {
            navigationAction.append(item)
        }

        navigationAction.removeIncluding(item)

        // Then
        let index: Int! = items.firstIndex(of: item)

        #expect(index != nil)
        #expect(navigationAction.count == index)
        #expect(state.stack == Array(items[0..<index]).map(AnyHashable.init))
    }

    @Test func navigationAction_whenSetItems_shouldBeEqual() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]

        // When
        navigationAction.setItems(items)

        // Then
        #expect(navigationAction.count == items.count)
        #expect(state.stack == items.map(AnyHashable.init))
    }

    @Test func navigationAction_whenSetItems_shouldRemoveAll() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]

        // When
        navigationAction.setItems(items)
        navigationAction.removeAll()

        // Then
        #expect(navigationAction.count == .zero)
        #expect(state.stack.isEmpty)
    }

    @Test func navigationAction_whenRemoveLastItem_shouldBeOneItemLeft() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]

        // When
        for item in items {
            navigationAction.append(item)
        }

        navigationAction.removeLast()

        // Then
        #expect(navigationAction.count == items.count - 1)
        #expect(state.stack == Array(items[0..<items.count - 1]).map(AnyHashable.init))
    }

    @Test func navigationAction_whenRemoveLastTwoItems_shouldBeTwoItemLeft() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]

        // When
        for item in items {
            navigationAction.append(item)
        }

        navigationAction.removeLast(2)

        // Then
        #expect(navigationAction.count == items.count - 2)
        #expect(state.stack == Array(items[0..<items.count - 2]).map(AnyHashable.init))
    }

    @Test func navigationAction_whenSetItems_shouldCodableBeEqual() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        // When
        navigationAction.setItems(items)

        // Then
        let encoded = try navigationAction.codable.map { try encoder.encode($0) }
        let expected = try state.codable.map { try encoder.encode($0) }
        #expect(encoded == expected)
    }

    @Test func navigationAction_whenTwoItems_shouldContainsOne() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let value = 1
        let items = [value, 2, 3, 4]

        // When
        navigationAction.setItems(items)

        // Then
        #expect(navigationAction.contains(value))
    }

    @Test func navigationAction_whenTwoItems_shouldNotContainsOne() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let value = 0
        let items = [1, 2, 3, 4]

        // When
        navigationAction.setItems(items)

        // Then
        #expect(!navigationAction.contains(value))
    }
}
