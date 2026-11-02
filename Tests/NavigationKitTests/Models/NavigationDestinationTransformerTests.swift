// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@MainActor
@Suite struct NavigationDestinationTransformerTests {

    let navigationState: NavigationStateMock
    let navigationAction: NavigationAction

    init() {
        let navigationState = NavigationStateMock()
        self.navigationState = navigationState
        navigationAction = .init(navigationState)
    }

    struct NotCodable<Value: Sendable>: Sendable, Hashable where Value: Hashable {
        let value: Value
    }

    @Test func transformer_whenAppendActionCodable_shouldContainsString() async throws {
        // Given
        let value = "Hello World"
        let sut = NavigationDestinationTransformer(.append)

        // When
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == [value])
    }

    @Test func transformer_whenSetItemsActionCodable_shouldBeValid() async throws {
        // Given
        let value = "Hello World"
        let sut = NavigationDestinationTransformer(.setItems)

        // When
        navigationAction.append(1)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == [value])
    }

    @Test func transformer_whenRemoveItemActionCodable_shouldBeEmpty() async throws {
        // Given
        let value = "Hello World"
        let sut = NavigationDestinationTransformer(.remove)

        // When
        navigationAction.append(value)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack.isEmpty)
    }

    @Test func transformer_whenRemoveUntilActionCodable_shouldBeValid() async throws {
        // Given
        let value = 2
        let items = [1, value, 3]
        let sut = NavigationDestinationTransformer(.removeUntil)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == Array(items[0...(items.firstIndex(of: value) ?? .zero)]).map(AnyHashable.init))
    }

    @Test func transformer_whenRemoveIncludingActionCodable_shouldBeValid() async throws {
        // Given
        let value = 2
        let items = [1, value, 3]
        let sut = NavigationDestinationTransformer(.removeIncluding)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == Array(items[0..<(items.firstIndex(of: value) ?? .zero)]).map(AnyHashable.init))
    }

    @Test func transformer_whenContainsCodable_shouldBeTrue() async throws {
        // Given
        let value = 2
        let items = Array(1...3)
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationAction.count == items.count)
    }

    @Test func transformer_whenContainsCodable_shouldBeFalse() async throws {
        // Given
        let value = 0
        let items = Array(1...3)
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationAction.count == items.count)
    }

    @Test func transformer_whenAppendAction_shouldContainsString() async throws {
        // Given
        let value = NotCodable(value: "Hello World")
        let sut = NavigationDestinationTransformer(.append)

        // When
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == [value])
    }

    @Test func transformer_whenSetItemsAction_shouldBeValid() async throws {
        // Given
        let value = NotCodable(value: "Hello World")
        let sut = NavigationDestinationTransformer(.setItems)

        // When
        navigationAction.append(1)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == [value])
    }

    @Test func transformer_whenRemoveItemAction_shouldBeEmpty() async throws {
        // Given
        let value = NotCodable(value: "Hello World")
        let sut = NavigationDestinationTransformer(.remove)

        // When
        navigationAction.append(value)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack.isEmpty)
    }

    @Test func transformer_whenRemoveUntilAction_shouldBeValid() async throws {
        // Given
        let value = NotCodable(value: 2)
        let items = [NotCodable(value: 1), value, NotCodable(value: 3)]
        let sut = NavigationDestinationTransformer(.removeUntil)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == Array(items[0...(items.firstIndex(of: value) ?? .zero)]).map(AnyHashable.init))
    }

    @Test func transformer_whenRemoveIncludingAction_shouldBeValid() async throws {
        // Given
        let value = NotCodable(value: 2)
        let items = [NotCodable(value: 1), value, NotCodable(value: 3)]
        let sut = NavigationDestinationTransformer(.removeIncluding)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationState.stack == Array(items[0..<(items.firstIndex(of: value) ?? .zero)]).map(AnyHashable.init))
    }

    @Test func transformer_whenContains_shouldBeTrue() async throws {
        // Given
        let value = NotCodable(value: 2)
        let items = (1...3).map {
            NotCodable(value: $0)
        }
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationAction.count == items.count)
    }

    @Test func transformer_whenContains_shouldBeFalse() async throws {
        // Given
        let value = NotCodable(value: 0)
        let items = (1...3).map {
            NotCodable(value: $0)
        }
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        #expect(navigationAction.count == items.count)
    }
}
