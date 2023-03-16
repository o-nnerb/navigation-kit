/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import SwiftUI
@testable import NavigationKit

class NavigationStateTests: XCTestCase {

    func testNavigationState_whenEmpty_shouldBeEmpty() async throws {
        // Given
        let navigationState = NavigationState()

        // Then
        XCTAssertEqual(navigationState.count, .zero)
    }

    func testNavigationState_whenAppendItems_shouldContainsItems() async throws {
        // Given
        let navigationState = NavigationState()
        let items = [1, 2, 3]

        // When
        for item in items {
            navigationState.append(item)
        }

        // Then
        XCTAssertEqual(navigationState.count, items.count)
    }

    func testNavigationState_whenAppendItems_shouldRemoveItem() async throws {
        // Given
        let navigationState = NavigationState()
        let item = 1
        let items = [item, 2, 3]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.remove(item)

        // Then
        XCTAssertEqual(navigationState.count, items.count - 1)
    }

    func testNavigationState_whenAppendItems_shouldRemoveUntilItem() async throws {
        // Given
        let navigationState = NavigationState()
        let item = 2
        let items = [1, item, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeUntil(item)

        // Then
        let index: Int! = items.firstIndex(of: item)

        XCTAssertNotNil(index)
        XCTAssertEqual(navigationState.count, index + 1)
    }

    func testNavigationState_whenAppendItems_shouldRemoveIncludingItem() async throws {
        // Given
        let navigationState = NavigationState()
        let item = 2
        let items = [1, item, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeIncluding(item)

        // Then
        let index: Int! = items.firstIndex(of: item)

        XCTAssertNotNil(index)
        XCTAssertEqual(navigationState.count, index)
    }

    func testNavigationState_whenSetItems_shouldBeEqual() async throws {
        // Given
        let navigationState = NavigationState()
        let items = [1, 2, 3, 4]

        // When
        navigationState.setItems(items)

        // Then
        XCTAssertEqual(navigationState.count, items.count)
    }

    func testNavigationState_whenSetItems_shouldRemoveAll() async throws {
        // Given
        let navigationState = NavigationState()
        let items = [1, 2, 3, 4]

        // When
        navigationState.setItems(items)
        navigationState.removeAll()

        // Then
        XCTAssertEqual(navigationState.count, .zero)
    }

    func testNavigationState_whenRemoveLastItem_shouldBeOneItemLeft() async throws {
        // Given
        let navigationState = NavigationState()
        let items = [1, 2, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeLast()

        // Then
        XCTAssertEqual(navigationState.count, items.count - 1)
    }

    func testNavigationState_whenRemoveLastTwoItems_shouldBeTwoItemLeft() async throws {
        // Given
        let navigationState = NavigationState()
        let items = [1, 2, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeLast(2)

        // Then
        XCTAssertEqual(navigationState.count, items.count - 2)
    }

    func testNavigationState_whenSetItems_shouldCodableBeEqual() async throws {
        // Given
        let navigationState = NavigationState()
        let items = [1, 2, 3, 4]

        let encoder = JSONEncoder()

        // When
        navigationState.setItems(items)

        // Then
        XCTAssertEqual(
            try navigationState.codable.map { try encoder.encode($0) },
            try NavigationPath(items).codable.map {
                try encoder.encode(NavigationAction.CodableRepresentation(
                    navigationPath: $0,
                    hashes: items.map(\.hashValue)
                ))
            }
        )
    }
}
