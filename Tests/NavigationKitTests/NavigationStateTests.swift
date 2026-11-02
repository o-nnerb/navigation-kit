// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import XCTest

@testable import NavigationKit

/// The behaviour every navigation state has to provide. Run against the system implementation and
/// the fallback one, which have to behave the same.
@MainActor
class NavigationStateTests: XCTestCase {

    /// The suite itself is abstract: only its subclasses run.
    override class var defaultTestSuite: XCTestSuite {
        self == NavigationStateTests.self
            ? XCTestSuite(name: "NavigationStateTests (abstract)") : super.defaultTestSuite
    }

    func makeState() -> NavigationStateProtocol {
        fatalError("Override makeState()")
    }

    /// Gives `state` the items a stack starts with, like the stack view does.
    func apply(_ pendingItems: PendingNavigationItems, to state: NavigationStateProtocol) {
        fatalError("Override apply(_:to:)")
    }

    /// A representation as saved by another launch of the app: `hashValue` is different on each
    /// launch, so the saved hashes mean nothing to this one.
    private var restoredFromAnotherLaunch: PendingNavigationItems {
        PendingNavigationItems(
            NavigationAction.CodableRepresentation(
                navigationPath: ["Swift.Int", "2", "Swift.Int", "1"],
                hashes: [1.hashValue &+ 7, 2.hashValue &+ 7]
            )
        )
    }

    func testNavigationState_whenEmpty_shouldBeEmpty() async throws {
        // Given
        let navigationState = makeState()

        // Then
        XCTAssertEqual(navigationState.count, .zero)
    }

    func testNavigationState_whenAppendItems_shouldContainsItems() async throws {
        // Given
        let navigationState = makeState()
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
        let navigationState = makeState()
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
        let navigationState = makeState()
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
        let navigationState = makeState()
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
        let navigationState = makeState()
        let items = [1, 2, 3, 4]

        // When
        navigationState.setItems(items)

        // Then
        XCTAssertEqual(navigationState.count, items.count)
    }

    func testNavigationState_whenSetItems_shouldRemoveAll() async throws {
        // Given
        let navigationState = makeState()
        let items = [1, 2, 3, 4]

        // When
        navigationState.setItems(items)
        navigationState.removeAll()

        // Then
        XCTAssertEqual(navigationState.count, .zero)
    }

    func testNavigationState_whenRemoveLastItem_shouldBeOneItemLeft() async throws {
        // Given
        let navigationState = makeState()
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
        let navigationState = makeState()
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
        let navigationState = makeState()
        let items = [1, 2, 3, 4]

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        // When
        navigationState.setItems(items)

        // Then
        XCTAssertEqual(
            try navigationState.codable.map { try encoder.encode($0) },
            try encoder.encode(
                NavigationAction.CodableRepresentation(
                    navigationPath: [
                        "Swift.Int", "4",
                        "Swift.Int", "3",
                        "Swift.Int", "2",
                        "Swift.Int", "1",
                    ],
                    hashes: items.map(\.hashValue)
                )
            )
        )
    }

    func testNavigationState_whenItemsAreNotCodable_shouldNotHaveCodable() async throws {
        // Given
        struct Item: Hashable {
            let id: Int
        }

        let navigationState = makeState()

        // When
        navigationState.setItems([Item(id: 1)])

        // Then
        XCTAssertNil(navigationState.codable)
    }

    // MARK: - Restored items

    func testNavigationState_whenRestored_shouldFindTheItems() async throws {
        // Given
        let navigationState = makeState()

        // When
        apply(restoredFromAnotherLaunch, to: navigationState)

        // Then
        XCTAssertEqual(navigationState.count, 2)
        XCTAssertTrue(navigationState.contains(1))
        XCTAssertTrue(navigationState.contains(2))
    }

    func testNavigationState_whenRestored_shouldRemoveAnItemKeepingTheOthers() async throws {
        // Given
        let navigationState = makeState()
        apply(restoredFromAnotherLaunch, to: navigationState)

        // When
        navigationState.remove(1)

        // Then
        XCTAssertEqual(navigationState.count, 1)
        XCTAssertFalse(navigationState.contains(1))
        XCTAssertTrue(navigationState.contains(2))
    }

    func testNavigationState_whenRestored_shouldRemoveIncludingAnItem() async throws {
        // Given
        let navigationState = makeState()
        apply(restoredFromAnotherLaunch, to: navigationState)

        // When
        navigationState.removeIncluding(2)

        // Then
        XCTAssertEqual(navigationState.count, 1)
        XCTAssertTrue(navigationState.contains(1))
    }

    func testNavigationState_whenRestored_shouldRemoveUntilAnItem() async throws {
        // Given
        let navigationState = makeState()
        apply(restoredFromAnotherLaunch, to: navigationState)

        // When
        navigationState.removeUntil(1)

        // Then
        XCTAssertEqual(navigationState.count, 1)
        XCTAssertTrue(navigationState.contains(1))
        XCTAssertFalse(navigationState.contains(2))
    }

    func testNavigationState_whenRestored_shouldCodableHaveTheHashesOfThisLaunch() async throws {
        // Given
        let navigationState = makeState()
        apply(restoredFromAnotherLaunch, to: navigationState)

        // Then
        XCTAssertEqual(navigationState.codable?.hashes, [1.hashValue, 2.hashValue])
    }

    func testNavigationState_whenStartedWithASequence_shouldRemoveAnItemKeepingTheOthers() async throws {
        // Given
        let navigationState = makeState()
        apply(PendingNavigationItems([1, 2, 3]), to: navigationState)

        // When
        navigationState.remove(2)

        // Then
        XCTAssertEqual(navigationState.count, 2)
        XCTAssertTrue(navigationState.contains(1))
        XCTAssertFalse(navigationState.contains(2))
        XCTAssertTrue(navigationState.contains(3))
    }
}

@available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
@MainActor
class SystemNavigationStateTests: NavigationStateTests {

    override func makeState() -> NavigationStateProtocol {
        NavigationState()
    }

    override func apply(_ pendingItems: PendingNavigationItems, to state: NavigationStateProtocol) {
        guard let state = state as? NavigationState else {
            return XCTFail("Expected a NavigationState")
        }

        _ = state[pendingItems]
    }
}

@MainActor
class FallbackNavigationStateTests: NavigationStateTests {

    override func makeState() -> NavigationStateProtocol {
        FallbackNavigationState()
    }

    override func apply(_ pendingItems: PendingNavigationItems, to state: NavigationStateProtocol) {
        guard let state = state as? FallbackNavigationState else {
            return XCTFail("Expected a FallbackNavigationState")
        }

        state.update(pendingItems)
    }
}

@MainActor
class FallbackNavigationStatePresentationTests: XCTestCase {

    /// Sets the items and lets each one appear, like the views of the stack do.
    private func show(_ items: [Int], in state: FallbackNavigationState) async {
        state.setItems(items)

        for level in 0..<items.count {
            await waitUntil { state.displayedCount > level }
            state.didAppear(at: level)
        }

        await waitUntil { state.displayedCount == items.count }
    }

    func testState_whenItemIsAppended_shouldBeDisplayedAtOnce() async throws {
        // Given
        let state = FallbackNavigationState()

        // When
        state.append(1)

        // Then
        XCTAssertEqual(state.count, 1)
        XCTAssertEqual(state.displayedCount, 1)
    }

    func testState_whenSeveralItemsAreSet_shouldDisplayThemOneAtATime() async throws {
        // Given
        let state = FallbackNavigationState()

        // When
        state.setItems([1, 2, 3])

        // Then
        XCTAssertEqual(state.count, 3)
        XCTAssertEqual(state.displayedCount, 1)

        await show([1, 2, 3], in: state)
        XCTAssertEqual(state.displayedCount, 3)
    }

    func testState_whenItemIsAppendedDuringAPush_shouldWaitForItToAppear() async throws {
        // Given
        let state = FallbackNavigationState()
        state.append(1)

        // When
        state.append(2)

        // Then
        XCTAssertEqual(state.count, 2)
        XCTAssertEqual(state.displayedCount, 1)

        state.didAppear(at: 0)
        XCTAssertEqual(state.displayedCount, 1, "The push of the first item is still in progress")

        await waitUntil { state.displayedCount == 2 }
        XCTAssertEqual(state.displayedCount, 2)
    }

    func testState_whenTheItemNeverAppears_shouldPushTheNextOneAnyway() async throws {
        // Given
        let state = FallbackNavigationState()
        state.append(1)

        // When
        state.append(2)

        // Then
        await waitUntil { state.displayedCount == 2 }
        XCTAssertEqual(state.displayedCount, 2)
    }

    func testState_whenItemsAreRemoved_shouldStopDisplayingThemAtOnce() async throws {
        // Given
        let state = FallbackNavigationState()
        await show([1, 2, 3], in: state)

        // When
        state.removeLast()

        // Then
        XCTAssertEqual(state.count, 2)
        XCTAssertEqual(state.displayedCount, 2)
    }

    func testState_whenTruncated_shouldKeepTheFirstItems() async throws {
        // Given
        let state = FallbackNavigationState()
        await show([1, 2, 3], in: state)

        // When
        state.truncate(to: 1)

        // Then
        XCTAssertEqual(state.count, 1)
        XCTAssertEqual(state.displayedCount, 1)
        XCTAssertTrue(state.contains(1))
        XCTAssertFalse(state.contains(2))
    }
}
