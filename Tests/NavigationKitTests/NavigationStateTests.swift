// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import Testing

@testable import NavigationKit

/// How to build a navigation state and give it the items a stack starts with, like the stack view does.
struct NavigationStateHarness: Sendable, CustomTestStringConvertible {

    let name: String
    let makeState: @MainActor @Sendable () -> NavigationStateProtocol
    let apply: @MainActor @Sendable (PendingNavigationItems, NavigationStateProtocol) -> Void

    var testDescription: String { name }

    /// The system implementation and the fallback one, which have to behave the same.
    static var all: [NavigationStateHarness] {
        var harnesses = [fallback]

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            harnesses.insert(system, at: 0)
        }

        return harnesses
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    private static var system: NavigationStateHarness {
        NavigationStateHarness(
            name: "NavigationState",
            makeState: { NavigationState() },
            apply: { pendingItems, state in
                guard let state = state as? NavigationState else {
                    Issue.record("Expected a NavigationState")
                    return
                }

                _ = state[pendingItems]
            }
        )
    }

    private static var fallback: NavigationStateHarness {
        NavigationStateHarness(
            name: "FallbackNavigationState",
            makeState: { FallbackNavigationState() },
            apply: { pendingItems, state in
                guard let state = state as? FallbackNavigationState else {
                    Issue.record("Expected a FallbackNavigationState")
                    return
                }

                state.update(pendingItems)
            }
        )
    }
}

/// The behaviour every navigation state has to provide, checked against each harness.
@MainActor
@Suite struct NavigationStateTests {

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

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenEmpty_shouldBeEmpty(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()

        // Then
        #expect(navigationState.count == .zero)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenAppendItems_shouldContainsItems(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let items = [1, 2, 3]

        // When
        for item in items {
            navigationState.append(item)
        }

        // Then
        #expect(navigationState.count == items.count)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenAppendItems_shouldRemoveItem(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let item = 1
        let items = [item, 2, 3]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.remove(item)

        // Then
        #expect(navigationState.count == items.count - 1)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenAppendItems_shouldRemoveUntilItem(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let item = 2
        let items = [1, item, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeUntil(item)

        // Then
        let index: Int! = items.firstIndex(of: item)

        #expect(index != nil)
        #expect(navigationState.count == index + 1)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenAppendItems_shouldRemoveIncludingItem(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let item = 2
        let items = [1, item, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeIncluding(item)

        // Then
        let index: Int! = items.firstIndex(of: item)

        #expect(index != nil)
        #expect(navigationState.count == index)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenSetItems_shouldBeEqual(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let items = [1, 2, 3, 4]

        // When
        navigationState.setItems(items)

        // Then
        #expect(navigationState.count == items.count)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenSetItems_shouldRemoveAll(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let items = [1, 2, 3, 4]

        // When
        navigationState.setItems(items)
        navigationState.removeAll()

        // Then
        #expect(navigationState.count == .zero)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRemoveLastItem_shouldBeOneItemLeft(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let items = [1, 2, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeLast()

        // Then
        #expect(navigationState.count == items.count - 1)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRemoveLastTwoItems_shouldBeTwoItemLeft(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let items = [1, 2, 3, 4]

        // When
        for item in items {
            navigationState.append(item)
        }

        navigationState.removeLast(2)

        // Then
        #expect(navigationState.count == items.count - 2)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenSetItems_shouldCodableBeEqual(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        let items = [1, 2, 3, 4]

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        // When
        navigationState.setItems(items)

        // Then
        let encoded = try navigationState.codable.map { try encoder.encode($0) }
        let expected = try encoder.encode(
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

        #expect(encoded == expected)
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenItemsAreNotCodable_shouldNotHaveCodable(_ harness: NavigationStateHarness) async throws {
        // Given
        struct Item: Hashable {
            let id: Int
        }

        let navigationState = harness.makeState()

        // When
        navigationState.setItems([Item(id: 1)])

        // Then
        #expect(navigationState.codable == nil)
    }

    // MARK: - Restored items

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRestored_shouldFindTheItems(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()

        // When
        harness.apply(restoredFromAnotherLaunch, navigationState)

        // Then
        #expect(navigationState.count == 2)
        #expect(navigationState.contains(1))
        #expect(navigationState.contains(2))
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRestored_shouldRemoveAnItemKeepingTheOthers(
        _ harness: NavigationStateHarness
    ) async throws {
        // Given
        let navigationState = harness.makeState()
        harness.apply(restoredFromAnotherLaunch, navigationState)

        // When
        navigationState.remove(1)

        // Then
        #expect(navigationState.count == 1)
        #expect(!navigationState.contains(1))
        #expect(navigationState.contains(2))
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRestored_shouldRemoveIncludingAnItem(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        harness.apply(restoredFromAnotherLaunch, navigationState)

        // When
        navigationState.removeIncluding(2)

        // Then
        #expect(navigationState.count == 1)
        #expect(navigationState.contains(1))
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRestored_shouldRemoveUntilAnItem(_ harness: NavigationStateHarness) async throws {
        // Given
        let navigationState = harness.makeState()
        harness.apply(restoredFromAnotherLaunch, navigationState)

        // When
        navigationState.removeUntil(1)

        // Then
        #expect(navigationState.count == 1)
        #expect(navigationState.contains(1))
        #expect(!navigationState.contains(2))
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenRestored_shouldCodableHaveTheHashesOfThisLaunch(
        _ harness: NavigationStateHarness
    ) async throws {
        // Given
        let navigationState = harness.makeState()
        harness.apply(restoredFromAnotherLaunch, navigationState)

        // Then
        #expect(navigationState.codable?.hashes == [1.hashValue, 2.hashValue])
    }

    @Test(arguments: NavigationStateHarness.all)
    func navigationState_whenStartedWithASequence_shouldRemoveAnItemKeepingTheOthers(
        _ harness: NavigationStateHarness
    ) async throws {
        // Given
        let navigationState = harness.makeState()
        harness.apply(PendingNavigationItems([1, 2, 3]), navigationState)

        // When
        navigationState.remove(2)

        // Then
        #expect(navigationState.count == 2)
        #expect(navigationState.contains(1))
        #expect(!navigationState.contains(2))
        #expect(navigationState.contains(3))
    }
}

@MainActor
@Suite struct FallbackNavigationStatePresentationTests {

    /// What the state asks the navigation about.
    @MainActor
    private final class FakeNavigation {
        var isIdle = false
        var landed = 0
    }

    /// Sets the items and lets each one appear, like the views of the stack do.
    private func show(_ items: [Int], in state: FallbackNavigationState) async {
        state.setItems(items)

        for level in 0..<items.count {
            await waitUntil { state.displayedCount > level }
            state.didAppear(at: level)
        }

        await waitUntil { state.displayedCount == items.count }
    }

    @Test func state_whenItemIsAppended_shouldBeDisplayedAtOnce() async throws {
        // Given
        let state = FallbackNavigationState()

        // When
        state.append(1)

        // Then
        #expect(state.count == 1)
        #expect(state.displayedCount == 1)
    }

    @Test func state_whenSeveralItemsAreSet_shouldDisplayThemOneAtATime() async throws {
        // Given
        let state = FallbackNavigationState()

        // When
        state.setItems([1, 2, 3])

        // Then
        #expect(state.count == 3)
        #expect(state.displayedCount == 1)

        await show([1, 2, 3], in: state)
        #expect(state.displayedCount == 3)
    }

    @Test func state_whenItemIsAppendedDuringAPush_shouldWaitForItToAppear() async throws {
        // Given
        let state = FallbackNavigationState()
        state.append(1)

        // When
        state.append(2)

        // Then
        #expect(state.count == 2)
        #expect(state.displayedCount == 1)

        state.didAppear(at: 0)
        #expect(state.displayedCount == 1, "The push of the first item is still in progress")

        await waitUntil { state.displayedCount == 2 }
        #expect(state.displayedCount == 2)
    }

    @Test func state_whenTheItemNeverAppears_shouldPushTheNextOneAnyway() async throws {
        // Given
        let state = FallbackNavigationState()
        state.append(1)

        // When
        state.append(2)

        // Then
        await waitUntil { state.displayedCount == 2 }
        #expect(state.displayedCount == 2)
    }

    @Test func state_whenItemsAreRemoved_shouldStopDisplayingThemAtOnce() async throws {
        // Given
        let state = FallbackNavigationState()
        await show([1, 2, 3], in: state)

        // When
        state.removeLast()

        // Then
        #expect(state.count == 2)
        #expect(state.displayedCount == 2)
    }

    @Test func state_whenTruncated_shouldKeepTheFirstItems() async throws {
        // Given
        let state = FallbackNavigationState()
        await show([1, 2, 3], in: state)

        // When
        state.truncate(to: 1)

        // Then
        #expect(state.count == 1)
        #expect(state.displayedCount == 1)
        #expect(state.contains(1))
        #expect(!state.contains(2))
    }

    @Test func state_whenTheNavigationIsNotIdle_shouldWaitToPush() async throws {
        // Given
        let state = FallbackNavigationState()
        let navigation = FakeNavigation()
        state.isReadyForPush = { _ in navigation.isIdle }

        // When
        state.append(1)

        // Then
        #expect(state.count == 1)
        #expect(state.displayedCount == 0)

        navigation.isIdle = true
        await waitUntil { state.displayedCount == 1 }
        #expect(state.displayedCount == 1)
    }

    @Test func state_whenTheNavigationIsIdle_shouldPushOneItemAtATimeAsItLands() async throws {
        // Given
        let state = FallbackNavigationState()
        let navigation = FakeNavigation()
        // The previous push has landed when the navigation shows as many items as the state says.
        state.isReadyForPush = { displayedCount in navigation.landed == displayedCount }

        // When
        state.setItems([1, 2, 3])
        #expect(state.displayedCount == 1)

        // Then
        navigation.landed = 1
        await waitUntil { state.displayedCount == 2 }
        #expect(state.displayedCount == 2)

        navigation.landed = 2
        await waitUntil { state.displayedCount == 3 }
        #expect(state.displayedCount == 3)
    }
}
