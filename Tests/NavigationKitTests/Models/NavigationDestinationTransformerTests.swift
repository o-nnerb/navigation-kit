/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class NavigationDestinationTransformerTests: XCTestCase {

    var navigationState: NavigationStateMock!
    var navigationAction: NavigationAction!

    override func setUp() async throws {
        try await super.setUp()
        let navigationState = NavigationStateMock()
        navigationAction = .init(navigationState)
        self.navigationState = navigationState
    }

    override func tearDown() async throws {
        try await super.tearDown()
        navigationState = nil
        navigationAction = nil
    }

    struct NotCodable<Value>: Hashable where Value: Hashable {
        let value: Value
    }

    func testTransformer_whenAppendActionCodable_shouldContainsString() async throws {
        // Given
        let value = "Hello World"
        let sut = NavigationDestinationTransformer(.append)

        // When
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, [value])
    }

    func testTransformer_whenSetItemsActionCodable_shouldBeValid() async throws {
        // Given
        let value = "Hello World"
        let sut = NavigationDestinationTransformer(.setItems)

        // When
        navigationAction.append(1)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, [value])
    }

    func testTransformer_whenRemoveItemActionCodable_shouldBeEmpty() async throws {
        // Given
        let value = "Hello World"
        let sut = NavigationDestinationTransformer(.remove)

        // When
        navigationAction.append(value)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertTrue(navigationState.stack.isEmpty)
    }

    func testTransformer_whenRemoveUntilActionCodable_shouldBeValid() async throws {
        // Given
        let value = 2
        let items = [1, value, 3]
        let sut = NavigationDestinationTransformer(.removeUntil)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, Array(items[0 ... (items.firstIndex(of: value) ?? .zero)]))
    }

    func testTransformer_whenRemoveIncludingActionCodable_shouldBeValid() async throws {
        // Given
        let value = 2
        let items = [1, value, 3]
        let sut = NavigationDestinationTransformer(.removeIncluding)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, Array(items[0 ..< (items.firstIndex(of: value) ?? .zero)]))
    }

    func testTransformer_whenContainsCodable_shouldBeTrue() async throws {
        // Given
        let value = 2
        let items = Array(1 ... 3)
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationAction.count, items.count)
    }

    func testTransformer_whenContainsCodable_shouldBeFalse() async throws {
        // Given
        let value = 0
        let items = Array(1 ... 3)
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationAction.count, items.count)
    }

    func testTransformer_whenAppendAction_shouldContainsString() async throws {
        // Given
        let value = NotCodable(value: "Hello World")
        let sut = NavigationDestinationTransformer(.append)

        // When
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, [value])
    }

    func testTransformer_whenSetItemsAction_shouldBeValid() async throws {
        // Given
        let value = NotCodable(value: "Hello World")
        let sut = NavigationDestinationTransformer(.setItems)

        // When
        navigationAction.append(1)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, [value])
    }

    func testTransformer_whenRemoveItemAction_shouldBeEmpty() async throws {
        // Given
        let value = NotCodable(value: "Hello World")
        let sut = NavigationDestinationTransformer(.remove)

        // When
        navigationAction.append(value)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertTrue(navigationState.stack.isEmpty)
    }

    func testTransformer_whenRemoveUntilAction_shouldBeValid() async throws {
        // Given
        let value = NotCodable(value: 2)
        let items = [NotCodable(value: 1), value, NotCodable(value: 3)]
        let sut = NavigationDestinationTransformer(.removeUntil)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, Array(items[0 ... (items.firstIndex(of: value) ?? .zero)]))
    }

    func testTransformer_whenRemoveIncludingAction_shouldBeValid() async throws {
        // Given
        let value = NotCodable(value: 2)
        let items = [NotCodable(value: 1), value, NotCodable(value: 3)]
        let sut = NavigationDestinationTransformer(.removeIncluding)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationState.stack, Array(items[0 ..< (items.firstIndex(of: value) ?? .zero)]))
    }

    func testTransformer_whenContains_shouldBeTrue() async throws {
        // Given
        let value = NotCodable(value: 2)
        let items = (1 ... 3).map {
            NotCodable(value: $0)
        }
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationAction.count, items.count)
    }

    func testTransformer_whenContains_shouldBeFalse() async throws {
        // Given
        let value = NotCodable(value: 0)
        let items = (1 ... 3).map {
            NotCodable(value: $0)
        }
        let sut = NavigationDestinationTransformer(.contains)

        // When
        navigationAction.setItems(items)
        sut(value)
        sut.perform(navigationAction)

        // Then
        XCTAssertEqual(navigationAction.count, items.count)
    }
}
