/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class NavigationActionTests: XCTestCase {
    
    var state: NavigationStateMock!
    
    override func setUp() async throws {
        try await super.setUp()
        state = NavigationStateMock()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        state = nil
    }
    
    func testNavigationAction_whenEmpty_shouldBeEmpty() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        
        // Then
        XCTAssertNotNil(state)
        XCTAssertTrue(state.stack.isEmpty)
        XCTAssertEqual(navigationAction.count, .zero)
    }
    
    func testNavigationAction_whenAppendItems_shouldContainsItems() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3]
        
        // When
        for item in items {
            navigationAction.append(item)
        }
        
        // Then
        XCTAssertEqual(navigationAction.count, items.count)
        XCTAssertEqual(state.stack, items)
    }
    
    func testNavigationAction_whenAppendItems_shouldRemoveItem() async throws {
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
        XCTAssertEqual(navigationAction.count, items.count - 1)
        XCTAssertEqual(state.stack, items.filter { $0 != item })
    }
    
    func testNavigationAction_whenAppendItems_shouldRemoveUntilItem() async throws {
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
        
        XCTAssertNotNil(index)
        XCTAssertEqual(navigationAction.count, index + 1)
        XCTAssertEqual(state.stack, Array(items[0 ... index]))
    }
    
    func testNavigationAction_whenAppendItems_shouldRemoveIncludingItem() async throws {
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
        
        XCTAssertNotNil(index)
        XCTAssertEqual(navigationAction.count, index)
        XCTAssertEqual(state.stack, Array(items[0 ..< index]))
    }
    
    func testNavigationAction_whenSetItems_shouldBeEqual() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]
        
        // When
        navigationAction.setItems(items)
        
        // Then
        XCTAssertEqual(navigationAction.count, items.count)
        XCTAssertEqual(state.stack, items)
    }
    
    func testNavigationAction_whenSetItems_shouldRemoveAll() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]
        
        // When
        navigationAction.setItems(items)
        navigationAction.removeAll()
        
        // Then
        XCTAssertEqual(navigationAction.count, .zero)
        XCTAssertTrue(state.stack.isEmpty)
    }
    
    func testNavigationAction_whenRemoveLastItem_shouldBeOneItemLeft() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]
        
        // When
        for item in items {
            navigationAction.append(item)
        }
        
        navigationAction.removeLast()
        
        // Then
        XCTAssertEqual(navigationAction.count, items.count - 1)
        XCTAssertEqual(state.stack, Array(items[0 ..< items.count - 1]))
    }
    
    func testNavigationAction_whenRemoveLastTwoItems_shouldBeTwoItemLeft() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]
        
        // When
        for item in items {
            navigationAction.append(item)
        }
        
        navigationAction.removeLast(2)
        
        // Then
        XCTAssertEqual(navigationAction.count, items.count - 2)
        XCTAssertEqual(state.stack, Array(items[0 ..< items.count - 2]))
    }
    
    func testNavigationAction_whenSetItems_shouldCodableBeEqual() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let items = [1, 2, 3, 4]
        
        let encoder = JSONEncoder()
        
        // When
        navigationAction.setItems(items)
        
        // Then
        XCTAssertEqual(
            try navigationAction.codable.map { try encoder.encode($0) },
            try state.codable.map { try encoder.encode($0) }
        )
    }
    
    func testNavigationAction_whenTwoItems_shouldContainsOne() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let value = 1
        let items = [value, 2, 3, 4]
        
        // When
        navigationAction.setItems(items)
        
        // Then
        XCTAssertTrue(navigationAction.contains(value))
    }
    
    func testNavigationAction_whenTwoItems_shouldNotContainsOne() async throws {
        // Given
        let navigationAction = NavigationAction(state)
        let value = 0
        let items = [1, 2, 3, 4]
        
        // When
        navigationAction.setItems(items)
        
        // Then
        XCTAssertFalse(navigationAction.contains(value))
    }
}
