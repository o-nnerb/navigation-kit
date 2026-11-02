// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI
import XCTest

@testable import NavigationKit

/// A stack that starts with items has to find them again, and to keep the others when one is removed.
@MainActor
class NavigationStackInitialItemsTests: XCTestCase {

    @MainActor
    private final class Recorder {
        var action: NavigationAction?
    }

    private struct Root: View {

        @Environment(\.navigationAction) var navigationAction
        let recorder: Recorder

        var body: some View {
            Color.clear
                .frame(width: 50, height: 50)
                .onAppear { recorder.action = navigationAction }
                .nkNavigationDestination(for: Int.self) { _ in
                    Color.clear.frame(width: 50, height: 50)
                }
        }
    }

    override func tearDown() async throws {
        NavigationBackend.forcesFallback = false
    }

    private func hostStack(
        _ recorder: Recorder,
        items: [Int]
    ) async -> AnyObject {
        let window = hostInWindow(
            NKNavigationStack(items) {
                Root(recorder: recorder)
            }
        )

        await waitUntil { recorder.action != nil }
        return window
    }

    private func assertRemovingKeepsTheOthers(_ recorder: Recorder) async throws {
        // Given
        let action = try XCTUnwrap(recorder.action)
        XCTAssertEqual(action.count, 3)
        XCTAssertTrue(action.contains(2))

        // When
        action.remove(2)

        // Then
        XCTAssertEqual(action.count, 2)
        XCTAssertTrue(action.contains(1))
        XCTAssertFalse(action.contains(2))
        XCTAssertTrue(action.contains(3))
    }

    func testStack_whenItStartsWithItems_shouldRemoveOneKeepingTheOthers() async throws {
        // Given
        let recorder = Recorder()
        let window = await hostStack(recorder, items: [1, 2, 3])

        // Then
        try await assertRemovingKeepsTheOthers(recorder)
        XCTAssertNotNil(window)
    }

    #if os(iOS) || os(tvOS) || os(macOS)
    func testFallbackStack_whenItStartsWithItems_shouldRemoveOneKeepingTheOthers() async throws {
        // Given
        NavigationBackend.forcesFallback = true
        let recorder = Recorder()
        let window = await hostStack(recorder, items: [1, 2, 3])

        // Then
        try await assertRemovingKeepsTheOthers(recorder)
        XCTAssertNotNil(window)
    }
    #endif
}
#endif
